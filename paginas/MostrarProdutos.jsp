<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (request.getParameter("categoria") == null) {
  out.println("Parâmetro de categoria em falta.");
  return;
}

String categoria = request.getParameter("categoria");

// Ordenação
String ordem = request.getParameter("ordem");
String orderBy = "p.id_produto";
if ("nome_asc".equals(ordem))   orderBy = "p.nome ASC";
if ("nome_desc".equals(ordem))  orderBy = "p.nome DESC";
if ("preco_asc".equals(ordem))  orderBy = "p.preco ASC";
if ("preco_desc".equals(ordem)) orderBy = "p.preco DESC";
if ("stock_asc".equals(ordem))  orderBy = "p.stock ASC";
if ("stock_desc".equals(ordem)) orderBy = "p.stock DESC";

String nome_categoria = categoria;

String sql = "SELECT p.id_produto, p.nome, p.descricao, p.preco, p.stock, p.categoria " +
             "FROM produto p " +
             "WHERE p.categoria = ? " +
             "AND p.ativo = 1 " +
             "ORDER BY " + orderBy;

List<Map<String, Object>> produtos = new ArrayList<>();
try {
    PreparedStatement stmt = conn.prepareStatement(sql);
    stmt.setString(1, categoria);
    ResultSet result = stmt.executeQuery();
    while (result.next()) {
        Map<String, Object> produto = new HashMap<>();
        produto.put("id_produto", result.getInt("id_produto"));
        produto.put("nome", result.getString("nome"));
        produto.put("descricao", result.getString("descricao"));
        produto.put("preco", result.getDouble("preco"));
        produto.put("stock", result.getInt("stock"));
        produto.put("categoria", result.getString("categoria"));
        produtos.add(produto);
    }
} catch (SQLException e) {
    out.println("Erro ao buscar produtos: " + e.getMessage());
}
%>

<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Produtos Disponíveis</title>
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
      margin: 100px auto;
      width: 90%;
      max-width: 900px;
      background: white;
      padding: 30px;
      border-radius: 10px;
      box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
    }

    h2 {
      text-align: center;
      color: #333;
    }

    .ordenar { margin: 15px 0; text-align: right; }
    .ordenar select { padding: 5px; border-radius: 4px; }

    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { border: 1px solid #ccc; padding: 10px; text-align: center; }
    th { background-color: hsl(122, 39.40%, 49.20%); color: white; }
  </style>
</head>

<body>

  <div class="navbar">
    <div class="nav-left">FelixUberShop</div>
    <div class="nav-right">
      <a href="index.jsp">Início</a>
      <a href="login.jsp">Login</a>
      <a href="registo.jsp">Registar</a>
    </div>
  </div>

  <div class="container">
    <h2>Produtos de <strong><%= nome_categoria %></strong></h2>

    <form method="get" class="ordenar">
      <input type="hidden" name="categoria" value="<%= categoria %>">
      <label for="ordem">Ordenar por:</label>
      <select name="ordem" id="ordem" onchange="this.form.submit()">
        <option value="">Nº (padrão)</option>
        <option value="nome_asc"   <%= "nome_asc".equals(ordem)   ? "selected" : "" %>>Nome (A-Z)</option>
        <option value="nome_desc"  <%= "nome_desc".equals(ordem)  ? "selected" : "" %>>Nome (Z-A)</option>
        <option value="preco_asc"  <%= "preco_asc".equals(ordem)  ? "selected" : "" %>>Preço (menor)</option>
        <option value="preco_desc" <%= "preco_desc".equals(ordem) ? "selected" : "" %>>Preço (maior)</option>
        <option value="stock_asc"  <%= "stock_asc".equals(ordem)  ? "selected" : "" %>>Stock (menor)</option>
        <option value="stock_desc" <%= "stock_desc".equals(ordem) ? "selected" : "" %>>Stock (maior)</option>
      </select>
    </form>

    <table>
      <tr>
        <th>Produto</th>
        <th>Categoria</th>
        <th>Descrição</th>
        <th>Stock</th>
        <th>Preço</th>
      </tr>
      <% for (Map<String, Object> produto : produtos) { %>
        <tr>
          <td><%= produto.get("nome") %></td>
          <td><%= produto.get("categoria") %></td>
          <td><%= produto.get("descricao") %></td>
          <td><%= produto.get("stock") %></td>
          <td><%= produto.get("preco") %> €</td>
        </tr>
      <% } %>
    </table>
  </div>

</body>
</html>
