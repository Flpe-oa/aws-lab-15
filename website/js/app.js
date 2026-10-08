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

/* ---------- Atualizar lista ---------- */

refreshButton.addEventListener("click", loadPosts);

/* Carrega os posts quando a página abre */
loadPosts();