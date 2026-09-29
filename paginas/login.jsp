<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (request.getParameter("id_produto") != null) {
    session.setAttribute("id_produto", request.getParameter("id_produto"));
}

String error = null;

if ("POST".equals(request.getMethod())) {
    String NOME = request.getParameter("nome");
    String PASSWORD = request.getParameter("password");

    String sql = "SELECT * FROM utilizador WHERE nomeUtilizador = ?";
    try {
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setString(1, NOME);
        ResultSet result = stmt.executeQuery();

        if (result.next()) {
            MessageDigest md = MessageDigest.getInstance("MD5");
            md.update(PASSWORD.getBytes());
            byte[] digest = md.digest();
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) {
                sb.append(String.format("%02x", b & 0xff));
            }
            String passwordMD5 = sb.toString();

            if (passwordMD5.equals(result.getString("pass"))) {
                session.setAttribute("id_utilizador", result.getInt("id_utilizador"));
                session.setAttribute("nomeUtilizador", result.getString("nomeUtilizador"));
                session.setAttribute("mail", result.getString("mail"));
                session.setAttribute("pass", result.getString("pass"));
                session.setAttribute("telemovel", result.getString("telemovel"));
                session.setAttribute("tipoUtilizador", result.getString("tipoUtilizador"));

                String tipoUtilizador = result.getString("tipoUtilizador");
                switch (tipoUtilizador) {
                    case "1": response.sendRedirect("PagIniAdmin.jsp"); break;
                    case "2": response.sendRedirect("PagIniCliente.jsp"); break;
                    case "3": response.sendRedirect("PagIniFuncionario.jsp"); break;
                    case "4": response.sendRedirect("PagIniClienteNaoValidado.jsp"); break;
                    default: response.sendRedirect("index.jsp");
                }
            } else {
                error = "Nome de utilizador ou palavra-passe inválidos.";
            }
        } else {
            error = "Nome de utilizador ou palavra-passe inválidos.";
        }
    } catch (Exception e) {
        out.println("Erro na consulta: " + e.getMessage());
    }
}
%>

<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Login</title>
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
      max-width: 400px;
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
    input[type="password"] {
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

    .registo-link {
      text-align: center;
      margin-top: 15px;
      font-size: 14px;
      color: #555;
    }

    .registo-link a {
      color: hsl(122, 39.40%, 49.20%);
      text-decoration: none;
      font-weight: bold;
    }

    .registo-link a:hover { text-decoration: underline; }
  </style>
</head>
<body>

  <div class="navbar">
    <div class="nav-left">FelixUberShop</div>
    <div class="nav-right">
      <a href="index.jsp">Início</a>
      <a href="registo.jsp">Registar</a>
    </div>
  </div>

  <div class="container">
    <h2>Login</h2>

    <div class="erro" <%= error == null ? "style='display:none'" : "" %>><%= error != null ? error : "" %></div>

    <form action="login.jsp" method="post">
      <label for="nome">Nome de utilizador:</label>
      <input type="text" id="nome" name="nome" required>

      <label for="password">Palavra-passe:</label>
      <input type="password" id="password" name="password" required>

      <button type="submit">Entrar</button>
    </form>

    <div class="registo-link">
      Não tens conta? <a href="registo.jsp">Regista-te aqui</a>
    </div>
  </div>

</body>
</html>