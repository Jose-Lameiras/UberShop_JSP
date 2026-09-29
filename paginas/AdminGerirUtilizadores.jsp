<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("1")) {
    response.sendRedirect("Logout.jsp");
    return;
}

String mailDelete = request.getParameter("delete");
if (mailDelete != null) {
    PreparedStatement ps = conn.prepareStatement("DELETE FROM utilizador WHERE mail = ?");
    ps.setString(1, mailDelete);
    ps.executeUpdate();
    ps.close();
    response.sendRedirect("AdminGerirUtilizadores.jsp");
    return;
}

String mailValidar = request.getParameter("validar");
if (mailValidar != null) {
    PreparedStatement ps = conn.prepareStatement("UPDATE utilizador SET tipoUtilizador = 2 WHERE mail = ?");
    ps.setString(1, mailValidar);
    ps.executeUpdate();
    ps.close();
    response.sendRedirect("AdminGerirUtilizadores.jsp");
    return;
}

String mailEliminarValidacao = request.getParameter("eliminar_validacao");
if (mailEliminarValidacao != null) {
    PreparedStatement ps = conn.prepareStatement("DELETE FROM utilizador WHERE mail = ?");
    ps.setString(1, mailEliminarValidacao);
    ps.executeUpdate();
    ps.close();
    response.sendRedirect("AdminGerirUtilizadores.jsp");
    return;
}

PreparedStatement psAll = conn.prepareStatement(
    "SELECT u.nomeUtilizador, u.mail, u.pass, u.telemovel, t.descricao " +
    "FROM utilizador u " +
    "JOIN tipoutilizador t ON u.tipoUtilizador = t.id_Tipo"
);
ResultSet rsAll = psAll.executeQuery();

List<Map<String, String>> utilizadores = new ArrayList<>();
while (rsAll.next()) {
    Map<String, String> row = new LinkedHashMap<>();
    row.put("nome", rsAll.getString("nomeUtilizador"));
    row.put("mail", rsAll.getString("mail"));
    row.put("mailEnc", java.net.URLEncoder.encode(rsAll.getString("mail"), "UTF-8"));
    row.put("pass", rsAll.getString("pass"));
    row.put("telemovel", rsAll.getString("telemovel"));
    row.put("tipo", rsAll.getString("descricao"));
    utilizadores.add(row);
}
rsAll.close();
psAll.close();

PreparedStatement psNaoValidados = conn.prepareStatement(
    "SELECT u.nomeUtilizador, u.mail, u.telemovel, t.descricao " +
    "FROM utilizador u " +
    "JOIN tipoutilizador t ON u.tipoUtilizador = t.id_Tipo " +
    "WHERE u.tipoUtilizador = 4"
);
ResultSet rsNaoValidados = psNaoValidados.executeQuery();

List<Map<String, String>> naoValidados = new ArrayList<>();
while (rsNaoValidados.next()) {
    Map<String, String> row = new LinkedHashMap<>();
    row.put("nome", rsNaoValidados.getString("nomeUtilizador"));
    row.put("mail", rsNaoValidados.getString("mail"));
    row.put("mailEnc", java.net.URLEncoder.encode(rsNaoValidados.getString("mail"), "UTF-8"));
    row.put("telemovel", rsNaoValidados.getString("telemovel"));
    row.put("tipo", rsNaoValidados.getString("descricao"));
    naoValidados.add(row);
}
rsNaoValidados.close();
psNaoValidados.close();
%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Gerir Utilizadores - Admin</title>
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
    .navbar a {
      color: white;
      text-decoration: none;
      margin-left: 20px;
      font-weight: bold;
    }
    .navbar a:hover { text-decoration: underline; }

    .container {
      margin: 100px auto 40px;
      width: 90%;
      max-width: 1200px;
      background: white;
      padding: 30px;
      border-radius: 10px;
      box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
    }

    .container + .container { margin-top: 30px; }

    h2 {
      text-align: center;
      color: #333;
      margin-bottom: 20px;
    }

    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th, td { border: 1px solid #ccc; padding: 10px; text-align: center; }
    th { background-color: hsl(122, 39.40%, 49.20%); color: white; }

    .btn {
      padding: 6px 12px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      text-decoration: none;
      font-size: 14px;
      display: inline-block;
    }
    .edit-btn     { background-color: hsl(122, 39.40%, 49.20%); color: white; }
    .edit-btn:hover { background-color: #388E3C; }
    .delete-btn   { background-color: #f44336; color: white; }
    .delete-btn:hover { background-color: #c62828; }
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
  <h2>Todos os Utilizadores</h2>
  <table>
    <tr>
      <th>Nome</th>
      <th>Email</th>
      <th>Password</th>
      <th>Telemóvel</th>
      <th>Tipo</th>
      <th>Editar</th>
      <th>Eliminar</th>
    </tr>
    <% for (Map<String, String> u : utilizadores) { %>
    <tr>
      <td><%= u.get("nome") %></td>
      <td><%= u.get("mail") %></td>
      <td><%= u.get("pass") %></td>
      <td><%= u.get("telemovel") %></td>
      <td><%= u.get("tipo") %></td>
      <td><a class="btn edit-btn" href="AdminEditarUtilizador.jsp?mail=<%= u.get("mailEnc") %>">Editar</a></td>
      <td><a class="btn delete-btn" href="?delete=<%= u.get("mailEnc") %>">Eliminar</a></td>
    </tr>
    <% } %>
  </table>
</div>

<div class="container">
  <h2>Validar ou Eliminar Utilizadores Pendentes</h2>
  <table>
    <tr>
      <th>Nome</th>
      <th>Email</th>
      <th>Telemóvel</th>
      <th>Tipo</th>
      <th>Validar</th>
      <th>Eliminar</th>
    </tr>
    <% if (naoValidados.isEmpty()) { %>
    <tr>
      <td colspan="6" style="text-align: center;">Não há utilizadores para validar</td>
    </tr>
    <% } else { for (Map<String, String> u : naoValidados) { %>
    <tr>
      <td><%= u.get("nome") %></td>
      <td><%= u.get("mail") %></td>
      <td><%= u.get("telemovel") %></td>
      <td><%= u.get("tipo") %></td>
      <td><a class="btn edit-btn" href="?validar=<%= u.get("mailEnc") %>">Validar</a></td>
      <td><a class="btn delete-btn" href="?eliminar_validacao=<%= u.get("mailEnc") %>">Eliminar</a></td>
    </tr>
    <% } } %>
  </table>
</div>

</body>
</html>
