<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("1")) {
    response.sendRedirect("Logout.jsp");
    return;
}

if (request.getParameter("delete") != null) {
    int idApagar = Integer.parseInt(request.getParameter("delete"));

    PreparedStatement psLinhas = conn.prepareStatement("DELETE FROM linha_encomenda WHERE id_produto = ?");
    psLinhas.setInt(1, idApagar);
    psLinhas.executeUpdate();
    psLinhas.close();

    PreparedStatement psProduto = conn.prepareStatement("DELETE FROM produto WHERE id_produto = ?");
    psProduto.setInt(1, idApagar);
    psProduto.executeUpdate();
    psProduto.close();

    response.sendRedirect("AdminGerirProdutos.jsp");
    return;
}

PreparedStatement ps = conn.prepareStatement(
    "SELECT id_produto, nome, descricao, stock, preco, categoria FROM produto ORDER BY id_produto"
);
ResultSet rs = ps.executeQuery();

List<Map<String, String>> produtos = new ArrayList<>();
while (rs.next()) {
    Map<String, String> row = new LinkedHashMap<>();
    row.put("id", String.valueOf(rs.getInt("id_produto")));
    row.put("nome", rs.getString("nome"));
    row.put("descricao", rs.getString("descricao"));
    row.put("categoria", rs.getString("categoria"));
    row.put("stock", String.valueOf(rs.getInt("stock")));
    row.put("preco", String.format("%.2f", rs.getDouble("preco")));
    produtos.add(row);
}
rs.close();
ps.close();
%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Gerir Produtos - Admin</title>
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
    <h2>Gerir Produtos</h2>

    <a href="AdminAdicionarProduto.jsp" class="btn add-btn">Adicionar um Produto</a>

    <table>
      <tr>
        <th>Nº</th>
        <th>Nome</th>
        <th>Descrição</th>
        <th>Categoria</th>
        <th>Stock</th>
        <th>Preço</th>
        <th>Editar</th>
        <th>Eliminar</th>
      </tr>
      <% for (Map<String, String> p : produtos) { %>
      <tr>
        <td><%= p.get("id") %></td>
        <td><%= p.get("nome") %></td>
        <td><%= p.get("descricao") %></td>
        <td><%= p.get("categoria") %></td>
        <td><%= p.get("stock") %></td>
        <td><%= p.get("preco") %> €</td>
        <td><a class="btn edit-btn" href="AdminEditarProduto.jsp?produto=<%= p.get("id") %>">Editar</a></td>
        <td><a class="btn delete-btn" href="?delete=<%= p.get("id") %>">Eliminar</a></td>
      </tr>
      <% } %>
    </table>
  </div>

</body>
</html>