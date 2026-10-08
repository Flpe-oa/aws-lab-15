const REGION = "us-east-1";
const CLIENT_ID = "71utepr0igeflh87gp5do5eime";
const API_URL = "https://1wqp1km8n1.execute-api.us-east-1.amazonaws.com/Dev";

/*
 * Token da sessão: fica só em memória.
 * Se a página for recarregada, é preciso entrar de novo.
 */
let accessToken = null;

/* ---------- Elementos do HTML ---------- */

const loginForm = document.getElementById("loginForm");
const loginSection = document.getElementById("loginSection");
const userSection = document.getElementById("userSection");
const logoutButton = document.getElementById("logoutButton");
const refreshButton = document.getElementById("refreshButton");
const statusText = document.getElementById("status");
const messageBox = document.getElementById("message");
const postForm = document.getElementById("postForm");
const postsContainer = document.getElementById("postsContainer");

/* Elementos relacionados ao upload de imagens */

const imageInput = document.getElementById("imageInput");
const uploadImageButton = document.getElementById("uploadImageButton");
const uploadStatus = document.getElementById("uploadStatus");

/* ---------- Utilitários ---------- */

/** Mostra uma mensagem para o usuário. type: "info" | "success" | "error" */
function showMessage(text, type = "info") {
  messageBox.textContent = text;
  messageBox.className = `message ${type}`;
  messageBox.hidden = false;
}

function clearMessage() {
  messageBox.hidden = true;
  messageBox.textContent = "";
}

/** Desabilita o botão de submit enquanto a requisição roda. */
function setLoading(form, isLoading) {
  const button = form.querySelector("button[type='submit']");
  if (button) button.disabled = isLoading;
}

function formatDate(value) {
  if (!value) return "";
  const date = new Date(value);
  if (isNaN(date.getTime())) return "";
  return date.toLocaleString("pt-BR", { dateStyle: "medium", timeStyle: "short" });
}

/** Volta para a tela de login (usado no logout e quando o token expira). */
function showLoggedOut() {
  accessToken = null;
  loginForm.reset();
  loginSection.hidden = false;
  userSection.hidden = true;
  statusText.textContent = "";
}

/* ---------- Posts ---------- */

async function loadPosts() {
  refreshButton.disabled = true;

  try {
    const response = await fetch(`${API_URL}/posts`);
    const posts = await response.json();

    if (!response.ok) {
      throw new Error(posts.message || "Erro ao carregar posts.");
    }

    postsContainer.innerHTML = "";

    if (!Array.isArray(posts) || posts.length === 0) {
      postsContainer.textContent =
        "Ainda não há posts. Entre com sua conta e publique o primeiro.";
      return;
    }

    // Mais recentes primeiro, quando o post tiver data de criação.
    const getDate = (p) => new Date(p.createdAt || p.created_at || 0).getTime();
    posts.sort((a, b) => getDate(b) - getDate(a));

    posts.forEach(function (post) {
      const article = document.createElement("article");
      article.className = "post";

      const title = document.createElement("h3");
      title.textContent = post.title;
      article.appendChild(title);

      const dateText = formatDate(post.createdAt || post.created_at);
      if (dateText) {
        const time = document.createElement("time");
        time.textContent = dateText;
        article.appendChild(time);
      }

      const content = document.createElement("p");
      content.textContent = post.content;
      article.appendChild(content);

      postsContainer.appendChild(article);
    });
  } catch (error) {
    console.error(error);
    postsContainer.textContent =
      "Não foi possível carregar os posts. Tente atualizar a lista.";
  } finally {
    refreshButton.disabled = false;
  }
}

/* ---------- Login ---------- */

loginForm.addEventListener("submit", async function (event) {
  event.preventDefault();

  const email = document.getElementById("email").value;
  const password = document.getElementById("password").value;

  showMessage("Entrando...", "info");
  setLoading(loginForm, true);

  try {
    const response = await fetch(`https://cognito-idp.${REGION}.amazonaws.com/`, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-amz-json-1.1",
        "X-Amz-Target": "AWSCognitoIdentityProviderService.InitiateAuth",
      },
      body: JSON.stringify({
        AuthFlow: "USER_PASSWORD_AUTH",
        ClientId: CLIENT_ID,
        AuthParameters: { USERNAME: email, PASSWORD: password },
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.message || "Erro ao realizar login.");
    }

    // Usuário criado pelo admin pode precisar trocar a senha no primeiro acesso.
    if (data.ChallengeName) {
      throw new Error(
        `O Cognito pediu uma etapa extra (${data.ChallengeName}). ` +
        "Defina uma senha permanente para o usuário e tente novamente."
      );
    }

    accessToken = data.AuthenticationResult.AccessToken;

    loginSection.hidden = true;
    userSection.hidden = false;
    statusText.textContent = `Conectado como ${email}`;

    showMessage("Login realizado com sucesso.", "success");
  } catch (error) {
    console.error(error);
    showMessage(error.message || "Erro ao realizar login.", "error");
  } finally {
    setLoading(loginForm, false);
  }
});

/* ---------- Logout ---------- */

logoutButton.addEventListener("click", function () {
  showLoggedOut();
  showMessage("Sessão encerrada.", "info");
});

/* ---------- Criar post ---------- */

postForm.addEventListener("submit", async function (event) {
  event.preventDefault();

  const title = document.getElementById("postTitle").value.trim();
  const content = document.getElementById("postContent").value.trim();

  showMessage("Publicando post...", "info");
  setLoading(postForm, true);

  try {
    const response = await fetch(`${API_URL}/posts`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({ title, content }),
    });

    const data = await response.json();

    // Token expirado ou inválido: pede novo login.
    if (response.status === 401 || response.status === 403) {
      showLoggedOut();
      showMessage("Sua sessão expirou. Entre novamente para publicar.", "error");
      return;
    }

    if (!response.ok) {
      throw new Error(data.message || "Erro ao criar post.");
    }

    showMessage("Post publicado com sucesso!", "success");
    postForm.reset();
    loadPosts(); // atualiza a lista sem recarregar a página
  } catch (error) {
    console.error(error);
    showMessage(error.message || "Erro ao criar post.", "error");
  } finally {
    setLoading(postForm, false);
  }
});
/* ---------- Upload de imagem ---------- */

/*
 * O upload acontece em duas etapas:
 *
 * 1. Pedimos para a API uma Presigned URL.
 * 2. Usamos essa URL para enviar o arquivo diretamente para o S3.
 *
 * A Lambda não recebe o arquivo.
 * Ela apenas gera uma autorização temporária para o upload.
 */

uploadImageButton.addEventListener("click", async function () {

  /* Verifica se o usuário escolheu algum arquivo */

  const file = imageInput.files[0];

  if (!file) {
    uploadStatus.textContent = "Selecione uma imagem antes de enviar.";
    return;
  }

  uploadImageButton.disabled = true;
  uploadStatus.textContent = "Preparando upload...";

  try {

    /*
     * ----------------------------------------------------
     * ETAPA 1
     * Solicitar uma Presigned URL para a nossa API
     * ----------------------------------------------------
     *
     * Enviamos para a Lambda:
     *
     * fileName → nome do arquivo
     * fileType → MIME type da imagem
     *
     * Exemplo:
     *
     * {
     *   "fileName": "foto.jpg",
     *   "fileType": "image/jpeg"
     * }
     */

    const response = await fetch(`${API_URL}/uploads/presigned-url`, {
      method: "POST",

      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${accessToken}`
      },

      body: JSON.stringify({
        fileName: file.name,
        fileType: file.type
      })
    });

    const data = await response.json();

    /*
     * Se o token estiver expirado ou inválido,
     * o usuário precisa fazer login novamente.
     */

    if (response.status === 401 || response.status === 403) {
      showLoggedOut();

      uploadStatus.textContent =
        "Sua sessão expirou. Entre novamente para enviar a imagem.";

      return;
    }

    /*
     * Verifica se a API retornou algum erro.
     */

    if (!response.ok) {
      throw new Error(
        data.message || "Não foi possível gerar a Presigned URL."
      );
    }

    /*
     * A Lambda devolveu a URL temporária que permite
     * fazer o upload diretamente para o S3.
     */

    const uploadUrl = data.url;

    if (!uploadUrl) {
      throw new Error("A API não retornou uma URL de upload.");
    }

    uploadStatus.textContent = "Enviando imagem para o S3...";

    /*
     * ----------------------------------------------------
     * ETAPA 2
     * Upload direto para o S3
     * ----------------------------------------------------
     *
     * Aqui o navegador envia o arquivo diretamente
     * para a URL gerada pela Lambda.
     */

    const uploadResponse = await fetch(uploadUrl, {
      method: "PUT",

      headers: {
        "Content-Type": file.type
      },

      body: file
    });

    /*
     * O S3 deve responder com sucesso (HTTP 200).
     */

    if (!uploadResponse.ok) {
      throw new Error("O S3 recusou o upload da imagem.");
    }

    /*
     * Upload concluído.
     */

    uploadStatus.textContent =
      `Imagem "${file.name}" enviada com sucesso!`;

  } catch (error) {

    console.error("Erro no upload:", error);

    uploadStatus.textContent =
      error.message || "Erro ao enviar a imagem.";

  } finally {

    /*
     * Reabilita o botão independentemente de
     * sucesso ou erro.
     */

    uploadImageButton.disabled = false;
  }
});

/* ---------- Atualizar lista ---------- */

refreshButton.addEventListener("click", loadPosts);

/* Carrega os posts quando a página abre */
loadPosts();