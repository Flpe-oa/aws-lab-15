const {
  DynamoDBClient,
  PutItemCommand,
  GetItemCommand,
  ScanCommand,
  UpdateItemCommand,
  DeleteItemCommand,
} = require("@aws-sdk/client-dynamodb");

const crypto = require("crypto");

const client = new DynamoDBClient({});

exports.handler = async (event) => {
  console.log(JSON.stringify(event, null, 2));
  console.log(
    "EVENTO RECEBIDO:",
    JSON.stringify(event, null, 2)
    );

  // ==========================================
  // GET /posts/{id}
  // Buscar um post específico
  // ==========================================
  if (event.routeKey === "GET /posts/{id}") {
    const postId = event.pathParameters.id;

    const result = await client.send(
      new GetItemCommand({
        TableName: process.env.TABLE_NAME,
        Key: {
          id: {
            S: postId,
          },
        },
      }),
    );

    if (!result.Item) {
      return {
        statusCode: 404,
        body: JSON.stringify({
          message: "Post não encontrado",
        }),
      };
    }

    return {
      statusCode: 200,
      body: JSON.stringify({
        id: result.Item.id.S,
        title: result.Item.title.S,
        content: result.Item.content.S,
      }),
    };
  }

  // ==========================================
  // GET /posts
  // Listar todos os posts
  // ==========================================
  if (event.routeKey === "GET /posts") {
    const result = await client.send(
      new ScanCommand({
        TableName: process.env.TABLE_NAME,
      }),
    );

    return {
      statusCode: 200,
      body: JSON.stringify(
        result.Items.map((item) => ({
          id: item.id.S,
          title: item.title.S,
          content: item.content.S,
        })),
      ),
    };
  }

  // ==========================================
  // POST /posts
  // Criar um post
  // ==========================================
  if (event.routeKey === "POST /posts") {
    let body;

    try {
      body = JSON.parse(event.body);
    } catch (error) {
      return {
        statusCode: 400,
        body: JSON.stringify({
          message: "JSON inválido",
        }),
      };
    }

    if (!body.title || !body.content) {
      return {
        statusCode: 400,
        body: JSON.stringify({
          message: "Campos obrigatórios ausentes",
        }),
      };
    }

    const postId = crypto.randomUUID();

    const item = {
      id: {
        S: postId,
      },
      title: {
        S: body.title,
      },
      content: {
        S: body.content,
      },
    };

    const command = new PutItemCommand({
      TableName: process.env.TABLE_NAME,
      Item: item,
    });

    await client.send(command);

    return {
      statusCode: 201,
      body: JSON.stringify({
        message: "Post criado com sucesso",
        id: postId,
      }),
    };
  }

  // ==========================================
  // PUT /posts/{id}
  // Atualizar um post
  // ==========================================
  if (event.routeKey === "PUT /posts/{id}") {
    const postId = event.pathParameters.id;

    let body;

    try {
      body = JSON.parse(event.body);
    } catch (error) {
      return {
        statusCode: 400,
        body: JSON.stringify({
          message: "JSON inválido",
        }),
      };
    }

    if (!body.title || !body.content) {
      return {
        statusCode: 400,
        body: JSON.stringify({
          message: "Campos obrigatórios ausentes",
        }),
      };
    }

    const result = await client.send(
      new UpdateItemCommand({
        TableName: process.env.TABLE_NAME,
        Key: {
          id: {
            S: postId,
          },
        },
        UpdateExpression: "SET #title = :title, #content = :content",
        ExpressionAttributeNames: {
          "#title": "title",
          "#content": "content",
        },
        ExpressionAttributeValues: {
          ":title": {
            S: body.title,
          },
          ":content": {
            S: body.content,
          },
        },
        ReturnValues: "ALL_NEW",
      }),
    );

    if (!result.Attributes) {
      return {
        statusCode: 404,
        body: JSON.stringify({
          message: "Post não encontrado",
        }),
      };
    }

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "Post atualizado com sucesso",
        post: {
          id: result.Attributes.id.S,
          title: result.Attributes.title.S,
          content: result.Attributes.content.S,
        },
      }),
    };
  }

  // ==========================================
  // DELETE /posts/{id}
  // Deletar um post
  // ==========================================
  if (event.routeKey === "DELETE /posts/{id}") {
    const postId = event.pathParameters.id;

    const result = await client.send(
      new DeleteItemCommand({
        TableName: process.env.TABLE_NAME,
        Key: {
          id: {
            S: postId,
          },
        },
        ReturnValues: "ALL_OLD",
      }),
    );

    if (!result.Attributes) {
      return {
        statusCode: 404,
        body: JSON.stringify({
          message: "Post não encontrado",
        }),
      };
    }

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "Post deletado com sucesso",
        id: postId,
      }),
    };
  }

  // ==========================================
  // Rota não encontrada
  // ==========================================
  return {
    statusCode: 404,
    body: JSON.stringify({
      message: "Rota não encontrada",
    }),
  };
};