<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("1")) {
    response.sendRedirect("Logout.jsp");
    return;
}

if (request.getParameter("delete") != null) {
    PreparedStatement ps = conn.prepareStatement("DELETE FROM promocao WHERE id_promocao = ?");
    ps.setInt(1, Integer.parseInt(request.getParameter("delete")));
    ps.executeUpdate();
    ps.close();
    response.sendRedirect("AdminGerirPromocoes.jsp");
    return;
}

if (request.getParameter("ativar") != null) {
    PreparedStatement ps = conn.prepareStatement("UPDATE promocao SET ativo = 1 WHERE id_promocao = ?");
    ps.setInt(1, Integer.parseInt(request.getParameter("ativar")));
    ps.executeUpdate();
    ps.close();
    response.sendRedirect("AdminGerirPromocoes.jsp");
    return;
}

if (request.getParameter("desativar") != null) {
    PreparedStatement ps = conn.prepareStatement("UPDATE promocao SET ativo = 0 WHERE id_promocao = ?");
    ps.setInt(1, Integer.parseInt(request.getParameter("desativar")));
    ps.executeUpdate();
    ps.close();
    response.sendRedirect("AdminGerirPromocoes.jsp");
    return;
}

PreparedStatement ps = conn.prepareStatement(
    "SELECT id_promocao, titulo, mensagem, data_inicio, data_fim, ativo FROM promocao ORDER BY id_promocao"
);
ResultSet rs = ps.executeQuery();

List<Map<String, String>> promocoes = new ArrayList<>();
while (rs.next()) {
    Map<String, String> row = new LinkedHashMap<>();
    row.put("id", String.valueOf(rs.getInt("id_promocao")));
    row.put("titulo", rs.getString("titulo"));
    row.put("mensagem", rs.getString("mensagem"));
    row.put("data_inicio", rs.getString("data_inicio"));
    row.put("data_fim", rs.getString("data_fim"));
    row.put("ativo", rs.getInt("ativo") == 1 ? "Sim" : "Não");
    row.put("ativoFlag", String.valueOf(rs.getInt("ativo")));
    promocoes.add(row);
}
rs.close();
ps.close();
%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Gerir Promoções/Informações - Admin</title>
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
      max-width: 1100px;
      background: white;
      padding: 30px;
      border-radius: 10px;
      box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
    }

    h2 {
      text-align: center;
      color: #333;
      margin-bottom: 20px;
    }

    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th, td { border: 1px solid #ccc; padding: 10px; text-align: center; }
    th { background-color: hsl(122, 39.40%, 49.20%); color: white; }

    .btn { padding: 6px 14px; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; font-size: 14px; }
    .edit-btn   { background-color: #4CAF50; color: white; }
    .edit-btn:hover { background-color: #388E3C; }
    .delete-btn { background-color: #f44336; color: white; }
    .delete-btn:hover { background-color: #c62828; }
    .add-btn    { background-color: rgb(54, 92, 244); color: white; margin-bottom: 20px; display: inline-block; }
    .add-btn:hover { background-color: #2a3fbf; }
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
    <h2>Gerir Promoções/Informações</h2>

    <a href="AdminAdicionarPromocao.jsp" class="btn add-btn">Adicionar uma Promoção/Informação</a>

    <table>
      <tr>
        <th>Nº</th>
        <th>Título</th>
        <th>Mensagem</th>
        <th>Data Início</th>
        <th>Data Fim</th>
        <th>Ativo</th>
        <th>Ativar/Desativar</th>
        <th>Editar</th>
        <th>Eliminar</th>
      </tr>
      <% for (Map<String, String> p : promocoes) { %>
      <tr>
        <td><%= p.get("id") %></td>
        <td><%= p.get("titulo") %></td>
        <td><%= p.get("mensagem") %></td>
        <td><%= p.get("data_inicio") %></td>
        <td><%= p.get("data_fim") %></td>
        <td><%= p.get("ativo") %></td>
        <td>
          <% if ("1".equals(p.get("ativoFlag"))) { %>
          <a class="btn delete-btn" href="?desativar=<%= p.get("id") %>">Desativar</a>
          <% } else { %>
          <a class="btn edit-btn" href="?ativar=<%= p.get("id") %>">Ativar</a>
          <% } %>
        </td>
        <td><a class="btn edit-btn" href="AdminEditarPromocao.jsp?promocao=<%= p.get("id") %>">Editar</a></td>
        <td><a class="btn delete-btn" href="?delete=<%= p.get("id") %>">Eliminar</a></td>
      </tr>
      <% } %>
    </table>
  </div>

</body>
</html>