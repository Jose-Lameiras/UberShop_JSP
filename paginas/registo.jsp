<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ include file="../basedados/basedados.h" %>
<%
String erro = "";
if ("POST".equals(request.getMethod())) {
    String NOME = request.getParameter("nome");
    String EMAIL = request.getParameter("email");
    String TELEFONE = request.getParameter("telefone");
    String PASSWORD = request.getParameter("senha");

    session.setAttribute("nome", NOME);
    session.setAttribute("email", EMAIL);
    session.setAttribute("telefone", TELEFONE);
    session.setAttribute("senha", PASSWORD);

    String passwordHash = "";
    try {
        MessageDigest md = MessageDigest.getInstance("MD5");
        md.update(PASSWORD.getBytes());
        byte[] digest = md.digest();
        StringBuilder sb = new StringBuilder();
        for (byte b : digest) {
            sb.append(String.format("%02x", b & 0xff));
        }
        passwordHash = sb.toString();
    } catch (Exception e) {
        out.println("Erro ao encriptar password: " + e.getMessage());
    }

    String sql = "INSERT INTO utilizador (nomeUtilizador, mail, pass, telemovel, tipoUtilizador) VALUES (?, ?, ?, ?, 4)";
    try {
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, NOME);
        ps.setString(2, EMAIL);
        ps.setString(3, passwordHash);
        ps.setString(4, TELEFONE);
        ps.executeUpdate();

        response.sendRedirect("registado.jsp");
        return;
    } catch (SQLException e) {
        if (e.getMessage().contains("telemovel")) {
            erro = "Já existe um utilizador com esse telemóvel.";
        } else if (e.getMessage().contains("mail")) {
            erro = "Já existe um utilizador com esse email.";
        } else {
            erro = "Não foi possível registar: " + e.getMessage();
        }
    }
}
%>

<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Registo</title>
  <style>
    *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: Arial, sans-serif;
      background-color: #f4f4f4;
      display: flex;
      flex-direction: column;
      align-items: center;
      padding-top: 100px;
      min-height: 100vh;
    }

    .navbar {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      background-color: hsl(122, 39.40%, 49.20%);
      color: white;
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 15px 30px;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
      z-index: 1000;
    }
    .navbar a { color: white; text-decoration: none; margin-left: 20px; font-weight: bold; }
    .navbar a:hover { text-decoration: underline; }

    .container {
      margin-top: 40px;
      width: 100%;
      max-width: 450px;
      background: white;
      padding: 30px 40px;
      border-radius: 10px;
      box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
    }

    h2 {
      text-align: center;
      color: #333;
      margin-bottom: 25px;
    }

    .erro {
      padding: 10px;
      background: #ffe8e8;
      border-left: 4px solid #f44336;
      margin-bottom: 15px;
      border-radius: 4px;
    }

    label {
      display: block;
      margin-top: 15px;
      margin-bottom: 5px;
      font-weight: bold;
      color: #333;
    }

    input[type="text"],
    input[type="email"],
    input[type="password"],
    input[type="tel"] {
      width: 100%;
      padding: 10px;
      border: 1px solid #ccc;
      border-radius: 6px;
      font-size: 14px;
    }

    input:focus {
      outline: none;
      border-color: hsl(122, 39.40%, 49.20%);
    }

    button[type="submit"] {
      width: 100%;
      padding: 12px;
      background-color: hsl(122, 39.40%, 49.20%);
      border: none;
      color: white;
      font-size: 16px;
      border-radius: 6px;
      cursor: pointer;
      margin-top: 20px;
    }

    button[type="submit"]:hover {
      background-color: #388E3C;
    }

    .login-link {
      text-align: center;
      margin-top: 15px;
      font-size: 14px;
      color: #555;
    }

    .login-link a {
      color: hsl(122, 39.40%, 49.20%);
      text-decoration: none;
      font-weight: bold;
    }

    .login-link a:hover { text-decoration: underline; }
  </style>
</head>
<body>

  <div class="navbar">
    <div class="nav-left">FelixUberShop</div>
    <div class="nav-right">
      <a href="index.jsp">Início</a>
      <a href="login.jsp">Login</a>
    </div>
  </div>

  <div class="container">
    <h2>Formulário de Registo</h2>

    <div class="erro" <%= erro.isEmpty() ? "style='display:none'" : "" %>><%= erro %></div>

    <form action="registo.jsp" method="post">
      <label for="nome">Nome:</label>
      <input type="text" id="nome" name="nome" required>

      <label for="email">Email:</label>
      <input type="email" id="email" name="email" required>

      <label for="telefone">Telefone:</label>
      <input type="tel" id="telefone" name="telefone" placeholder="Ex: 912345678" required pattern="[0-9]{9}">

      <label for="senha">Palavra-passe:</label>
      <input type="password" id="senha" name="senha" required>

      <button type="submit">Registar</button>
    </form>

    <div class="login-link">
      Já tem conta? <a href="login.jsp">Faça login aqui</a>
    </div>
  </div>

</body>
</html>