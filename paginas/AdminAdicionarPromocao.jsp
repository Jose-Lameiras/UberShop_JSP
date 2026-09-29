<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("1")) {
    response.sendRedirect("Logout.jsp");
    return;
}

if ("POST".equals(request.getMethod())) {
    String titulo      = request.getParameter("titulo");
    String mensagem    = request.getParameter("mensagem");
    String data_inicio = request.getParameter("data_inicio");
    String data_fim    = request.getParameter("data_fim");
    int ativo          = request.getParameter("ativo") != null ? 1 : 0;

    PreparedStatement ps = conn.prepareStatement(
        "INSERT INTO promocao (titulo, mensagem, data_inicio, data_fim, ativo) VALUES (?, ?, ?, ?, ?)"
    );
    ps.setString(1, titulo);
    ps.setString(2, mensagem);
    ps.setString(3, data_inicio);
    ps.setString(4, data_fim);
    ps.setInt(5, ativo);

    if (ps.executeUpdate() > 0) {
%>
        <script>alert('Promoção adicionada com sucesso!'); window.location.href='AdminGerirPromocoes.jsp';</script>
<%
    } else {
%>
        <script>alert('Erro ao adicionar promoção.');</script>
<%
    }
    ps.close();
}
%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Adicionar Promoção - Admin</title>
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
      max-width: 500px;
      background: white;
      padding: 30px;
      border-radius: 10px;
      box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
    }

    h2 { text-align: center; color: #333; margin-bottom: 20px; }

    label { margin-top: 15px; display: block; font-weight: bold; }

    input, textarea {
      width: 100%;
      padding: 8px;
      margin-top: 5px;
      border-radius: 4px;
      border: 1px solid #ccc;
    }
    input:focus, textarea:focus {
      outline: none;
      border-color: hsl(122, 39.40%, 49.20%);
      box-shadow: 0 0 0 2px rgba(76, 175, 80, 0.2);
    }

    .checkbox-label { display: flex; align-items: center; gap: 8px; margin-top: 15px; font-weight: bold; }
    .checkbox-label input { width: auto; margin: 0; }

    .btn { margin-top: 20px; padding: 10px 20px; border: none; cursor: pointer; border-radius: 4px; }
    .save-btn { background-color: hsl(122, 39.40%, 49.20%); color: white; }
    .save-btn:hover { background-color: #388E3C; }
  </style>
</head>
<body>

<div class="navbar">
  <div class="nav-left">FelixUberShop - Admin</div>
  <div class="nav-right">
    <a href="AdminGerirPromocoes.jsp">Voltar</a>
    <a href="Logout.jsp">Log Out</a>
  </div>
</div>

<div class="container">
  <h2>Adicionar Nova Promoção</h2>

  <form method="POST">
    <label>Título</label>
    <input type="text" name="titulo" required>

    <label>Mensagem</label>
    <textarea name="mensagem" rows="4" required></textarea>

    <label>Data Início</label>
    <input type="date" name="data_inicio" required>

    <label>Data Fim</label>
    <input type="date" name="data_fim" required>

    <label class="checkbox-label">
      <input type="checkbox" name="ativo" checked> Ativo
    </label>

    <button class="btn save-btn" type="submit">Adicionar Promoção</button>
  </form>
</div>

</body>
</html>