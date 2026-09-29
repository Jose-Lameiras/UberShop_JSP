<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("3")) {
    response.sendRedirect("Logout.jsp");
    return;
}

int id_utilizador = (Integer) session.getAttribute("id_utilizador");
String sql="SELECT nomeUtilizador, mail, telemovel FROM utilizador WHERE id_utilizador = ?";

PreparedStatement ps = conn.prepareStatement(sql);
ps.setInt(1, id_utilizador);
ResultSet res = ps.executeQuery();
res.next();

String nomeUtilizador = res.getString("nomeUtilizador");
String mail = res.getString("mail");
String telemovel = res.getString("telemovel");
%>
<!DOCTYPE html>
<html lang="pt">

<head>
  <meta charset="UTF-8">
  <title>Perfil Funcionário</title>
  <style>
    *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: Arial, sans-serif;
      background-color: #f4f4f4;
      display: flex; flex-direction: column; align-items: center;
      padding-top: 100px; min-height: 100vh;
    }

    .navbar {
      position: fixed; top: 0; left: 0; width: 100%;
      background-color: hsl(122, 39.40%, 49.20%); color: white;
      display: flex; justify-content: space-between; align-items: center;
      padding: 15px 30px; box-shadow: 0 2px 8px rgba(0,0,0,0.2); z-index: 1000;
    }
    .navbar a { color: white; text-decoration: none; margin-left: 20px; font-weight: bold; }
    .navbar a:hover { text-decoration: underline; }

    .perfil-container {
      background: #fff; padding: 32px 48px; border-radius: 14px;
      box-shadow: 0 4px 18px rgba(0,0,0,0.10); margin-top: 30px;
      min-width: 340px; max-width: 400px;
    }
    .perfil-container h2 { color: #2e7d32; margin-bottom: 24px; text-align: center; }

    .perfil-dados { margin-bottom: 18px; }
    .perfil-dados p { margin-bottom: 10px; }

    .btn {
      display: block; width: 100%; padding: 12px 32px;
      background: hsl(122, 39.40%, 49.20%); color: #fff;
      border: none; border-radius: 8px; font-size: 16px;
      cursor: pointer; text-align: center; text-decoration: none;
    }
    .btn:hover { background: #0056b3; }
  </style>
</head>

<body>

<div class="navbar">
  <div class="nav-left">Perfil</div>
  <div class="nav-right">
    <a href="PagIniFuncionario.jsp">Voltar</a>
    <a href="Logout.jsp">Log Out</a>
  </div>
</div>

<div class="perfil-container">
  <h2>Meus Dados</h2>
  <div class="perfil-dados">
    <p><strong>Nome:</strong> <%= nomeUtilizador %></p>
    <p><strong>Email:</strong> <%= mail %></p>
    <p><strong>Telemóvel:</strong> <%= telemovel %></p>
  </div>
  <a href="FuncEditarPerfil.jsp" class="btn">Editar Dados</a>
</div>

</body>
</html>
