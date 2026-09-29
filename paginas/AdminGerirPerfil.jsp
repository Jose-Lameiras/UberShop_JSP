<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("1")) {
    response.sendRedirect("Logout.jsp");
    return;
}

int id_utilizador = (Integer) session.getAttribute("id_utilizador");

String nomeUtilizador = "";
String mail = "";
String telemovel = "";

PreparedStatement ps = conn.prepareStatement("SELECT nomeUtilizador, mail, telemovel FROM utilizador WHERE id_utilizador = ?");
ps.setInt(1, id_utilizador);
ResultSet res = ps.executeQuery();
if (res.next()) {
    nomeUtilizador = res.getString("nomeUtilizador");
    mail = res.getString("mail");
    telemovel = res.getString("telemovel");
}
res.close();
ps.close();
%>

<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Perfil Admin</title>
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

    .perfil-dados { margin-bottom: 20px; }
    .perfil-dados p { margin-bottom: 10px; font-size: 15px; }

    .btn {
      width: 100%;
      padding: 12px;
      background-color: hsl(122, 39.40%, 49.20%);
      color: white;
      border: none;
      border-radius: 6px;
      font-size: 16px;
      cursor: pointer;
    }
    .btn:hover { background-color: #388E3C; }
  </style>
</head>
<body>

  <div class="navbar">
    <div class="nav-left">FelixUberShop - Admin</div>
    <div class="nav-right">
      <a href="PagIniAdmin.jsp">Voltar</a>
      <a href="Logout.jsp">Log Out</a>
    </div>
  </div>

  <div class="container">
    <h2>Perfil do Admin</h2>
    <div class="perfil-dados">
      <p><strong>Nome:</strong> <%= nomeUtilizador %></p>
      <p><strong>Email:</strong> <%= mail %></p>
      <p><strong>Telemóvel:</strong> <%= telemovel %></p>
    </div>
    <form action="AdminEditarPerfil.jsp" method="get">
      <button class="btn" type="submit">Editar Dados</button>
    </form>
  </div>

</body>
</html>