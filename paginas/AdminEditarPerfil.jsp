<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("1")) {
    response.sendRedirect("Logout.jsp");
    return;
}

int id_utilizador = (Integer) session.getAttribute("id_utilizador");
String erro = "";

if ("POST".equals(request.getMethod())) {
    String nome = request.getParameter("nomeUtilizador");
    String mail = request.getParameter("mail");
    String telemovel = request.getParameter("telemovel");
    String pass = request.getParameter("pass");

    try {
        if (pass != null && !pass.trim().isEmpty()) {
            MessageDigest md = MessageDigest.getInstance("MD5");
            md.update(pass.getBytes());
            byte[] digest = md.digest();
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) {
                sb.append(String.format("%02x", b & 0xff));
            }
            String pass_encriptada = sb.toString();

            PreparedStatement ps = conn.prepareStatement(
                "UPDATE utilizador SET nomeUtilizador=?, mail=?, telemovel=?, pass=? WHERE id_utilizador=?"
            );
            ps.setString(1, nome);
            ps.setString(2, mail);
            ps.setString(3, telemovel);
            ps.setString(4, pass_encriptada);
            ps.setInt(5, id_utilizador);
            ps.executeUpdate();
            ps.close();
        } else {
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE utilizador SET nomeUtilizador=?, mail=?, telemovel=? WHERE id_utilizador=?"
            );
            ps.setString(1, nome);
            ps.setString(2, mail);
            ps.setString(3, telemovel);
            ps.setInt(4, id_utilizador);
            ps.executeUpdate();
            ps.close();
        }
        response.sendRedirect("AdminGerirPerfil.jsp");
        return;
    } catch (SQLException e) {
        if (e.getMessage().contains("telemovel")) {
            erro = "Já existe um utilizador com esse telemóvel.";
        } else if (e.getMessage().contains("mail")) {
            erro = "Já existe um utilizador com esse email.";
        } else {
            erro = "Erro ao atualizar dados: " + e.getMessage();
        }
    }
}

PreparedStatement ps = conn.prepareStatement(
    "SELECT nomeUtilizador, mail, telemovel FROM utilizador WHERE id_utilizador = ?"
);
ps.setInt(1, id_utilizador);
ResultSet res = ps.executeQuery();
%>

<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Editar Perfil - Admin</title>
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
      margin: 100px auto;
      width: 90%;
      max-width: 450px;
      background: white;
      padding: 30px;
      border-radius: 10px;
      box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
    }

    h2 { text-align: center; color: #333; margin-bottom: 20px; }

    .erro { padding: 10px; background: #ffe8e8; border-left: 4px solid #f44336; margin-bottom: 15px; border-radius: 4px; }

    label { display: block; margin-top: 15px; margin-bottom: 5px; font-weight: bold; }

    input {
      width: 100%;
      padding: 8px;
      border-radius: 4px;
      border: 1px solid #ccc;
    }
    input:focus {
      outline: none;
      border-color: hsl(122, 39.40%, 49.20%);
    }

    .btn { margin-top: 20px; width: 100%; padding: 12px; border: none; cursor: pointer; border-radius: 6px; font-size: 15px; }
    .save-btn { background-color: hsl(122, 39.40%, 49.20%); color: white; }
    .save-btn:hover { background-color: #388E3C; }
    .back-btn { background-color: #888; color: white; margin-top: 10px; }
    .back-btn:hover { background-color: #555; }
  </style>
</head>
<body>

  <div class="navbar">
    <div class="nav-left">FelixUberShop - Admin</div>
    <div class="nav-right">
      <a href="AdminGerirPerfil.jsp">Voltar</a>
      <a href="Logout.jsp">Log Out</a>
    </div>
  </div>

  <div class="container">
    <h2>Editar Perfil</h2>

    <div class="erro" <%= erro.isEmpty() ? "style='display:none'" : "" %>><%= erro %></div>

    <% if (res.next()) { %>
    <form method="post">
      <label>Nome:</label>
      <input type="text" name="nomeUtilizador" value="<%= res.getString("nomeUtilizador") %>" required>

      <label>Email:</label>
      <input type="email" name="mail" value="<%= res.getString("mail") %>" required>

      <label>Telemóvel:</label>
      <input type="text" name="telemovel" value="<%= res.getString("telemovel") %>" required>

      <label>Nova Password (opcional):</label>
      <input type="password" name="pass" placeholder="Deixe em branco para não alterar">

      <button class="btn save-btn" type="submit">Guardar Alterações</button>
      <button class="btn back-btn" type="button" onclick="window.location.href='AdminGerirPerfil.jsp'">Voltar para o Perfil</button>
    </form>
    <% } %>
  </div>

</body>
</html>