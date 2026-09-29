<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("1")) {
    response.sendRedirect("Logout.jsp");
    return;
}

if (request.getParameter("promocao") == null) {
    out.println("Promoção não fornecida.");
    return;
}

int promocao = Integer.parseInt(request.getParameter("promocao"));

PreparedStatement psSelect = conn.prepareStatement("SELECT * FROM promocao WHERE id_promocao = ?");
psSelect.setInt(1, promocao);
ResultSet result = psSelect.executeQuery();
if (!result.next()) {
    out.println("Promoção não encontrada na base de dados.");
    return;
}

String titulo      = result.getString("titulo");
String mensagem    = result.getString("mensagem");
String data_inicio = result.getString("data_inicio");
String data_fim    = result.getString("data_fim");
int ativo          = result.getInt("ativo");
result.close();
psSelect.close();

if ("POST".equals(request.getMethod())) {
    String novoTitulo     = request.getParameter("titulo");
    String novaMensagem   = request.getParameter("mensagem");
    String novaDataInicio = request.getParameter("data_inicio");
    String novaDataFim    = request.getParameter("data_fim");
    int novoAtivo         = request.getParameter("ativo") != null ? 1 : 0;

    PreparedStatement psUpdate = conn.prepareStatement(
        "UPDATE promocao SET titulo=?, mensagem=?, data_inicio=?, data_fim=?, ativo=? WHERE id_promocao=?"
    );
    psUpdate.setString(1, novoTitulo);
    psUpdate.setString(2, novaMensagem);
    psUpdate.setString(3, novaDataInicio);
    psUpdate.setString(4, novaDataFim);
    psUpdate.setInt(5, novoAtivo);
    psUpdate.setInt(6, promocao);
    psUpdate.executeUpdate();
    psUpdate.close();
%>
    <script>alert('Promoção/informação atualizada com sucesso!'); window.location.href='AdminGerirPromocoes.jsp';</script>
<%
}
%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Editar Promoção/Informação - Admin</title>
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
  <h2>Editar Promoção/Informação</h2>

  <form method="POST">
    <label>Título</label>
    <input type="text" name="titulo" value="<%= titulo %>" required>

    <label>Mensagem</label>
    <textarea name="mensagem" rows="4" required><%= mensagem %></textarea>

    <label>Data Início</label>
    <input type="date" name="data_inicio" value="<%= data_inicio %>" required>

    <label>Data Fim</label>
    <input type="date" name="data_fim" value="<%= data_fim %>" required>

    <label class="checkbox-label">
      <input type="checkbox" name="ativo" <%= ativo == 1 ? "checked" : "" %>> Ativo
    </label>

    <button class="btn save-btn" type="submit">Guardar Alterações</button>
  </form>
</div>

</body>
</html>