const REGION = "us-east-1";

const CLIENT_ID = "71utepr0igeflh87gp5do5eime";

const API_URL =
  "https://1wqp1km8n1.execute-api.us-east-1.amazonaws.com/Dev";

/*
 * TOKEN DA SESSÃO
 *
 * Por enquanto fica apenas na memória
 * enquanto a página estiver aberta.
 */

let accessToken = null;

/*
 * ELEMENTOS DO HTML
 */

const loginForm = document.getElementById("loginForm");

const loginSection = document.getElementById("loginSection");

const userSection = document.getElementById("userSection");

const logoutButton = document.getElementById("logoutButton");

const status = document.getElementById("status");

const message = document.getElementById("message");

const postForm = document.getElementById("postForm");

const postsContainer = document.getElementById("postsContainer");

/*
 * CARREGAR POSTS
 */

async function loadPosts() {
  try {
    const response = await fetch(`${API_URL}/posts`);

    const posts = await response.json();

    if (!response.ok) {
      throw new Error(
        posts.message || "Erro ao carregar posts.",
      );
    }

    /*
     * Limpa a mensagem
     * "Carregando posts..."
     */

    postsContainer.innerHTML = "";

    /*
     * Verifica se existem posts.
     */

    if (posts.length === 0) {
      postsContainer.textContent = "Nenhum post encontrado.";
      return;
    }

    /*
     * Cria o HTML de cada post.
     */

    posts.forEach(function (post) {
      const article = document.createElement("article");

      const title = document.createElement("h3");

      const content = document.createElement("p");

      title.textContent = post.title;

      content.textContent = post.content;

      article.appendChild(title);

      article.appendChild(content);

      postsContainer.appendChild(article);
    });
  } catch (error) {
    console.error(error);

    postsContainer.textContent = "Erro ao carregar os posts.";
  }
}

/*
 * LOGIN
 */

loginForm.addEventListener("submit", async function (event) {
  event.preventDefault();

  const email = document.getElementById("email").value;

  const password = document.getElementById("password").value;

  message.textContent = "Realizando login...";

  try {
    const response = await fetch(
      `https://cognito-idp.${REGION}.amazonaws.com/`,
      {
        method: "POST",

        headers: {
          "Content-Type": "application/x-amz-json-1.1",

          "X-Amz-Target":
            "AWSCognitoIdentityProviderService.InitiateAuth",
        },

        body: JSON.stringify({
          AuthFlow: "USER_PASSWORD_AUTH",

          ClientId: CLIENT_ID,

          AuthParameters: {
            USERNAME: email,

            PASSWORD: password,
          },
        }),
      },
    );

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.message || "Erro ao realizar login.");
    }

    /*
     * Guardamos o Access Token.
     */

    accessToken = data.AuthenticationResult.AccessToken;

    /*
     * Atualizamos a interface.
     */

    loginSection.hidden = true;

    userSection.hidden = false;

    status.textContent = `Autenticado como ${email}`;

    message.textContent = "Login realizado com sucesso.";

    console.log(
      "Login realizado. AccessToken recebido:",
      Boolean(accessToken),
    );
  } catch (error) {
    console.error(error);

    message.textContent =
      error.message || "Erro ao realizar login.";
  }
});

/*
 * LOGOUT
 */

logoutButton.addEventListener("click", function () {
  /*
   * Remove o token da memória.
   */

  accessToken = null;

  /*
   * Limpa o formulário.
   */

  loginForm.reset();

  /*
   * Volta para a tela de login.
   */

  loginSection.hidden = false;

  userSection.hidden = true;

  status.textContent = "";

  message.textContent = "Sessão encerrada.";

  console.log("Logout realizado.");
});

/*
 * CRIAR POST
 */

postForm.addEventListener("submit", async function (event) {
  event.preventDefault();

  const title = document.getElementById("postTitle").value;

  const content = document.getElementById("postContent").value;

  message.textContent = "Criando post...";

  try {
    const response = await fetch(`${API_URL}/posts`, {
      method: "POST",

      headers: {
        "Content-Type": "application/json",

        Authorization: `Bearer ${accessToken}`,
      },

      body: JSON.stringify({
        title: title,

        content: content,
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.message || "Erro ao criar post.");
    }

    message.textContent =
      `Post criado com sucesso! ID: ${data.id}`;

    postForm.reset();

    console.log("Post criado:", data);
  } catch (error) {
    console.error(error);

    message.textContent =
      error.message || "Erro ao criar post.";
  }
  
});

/* * CARREGA OS POSTS QUANDO A PÁGINA ABRE */ loadPosts();

