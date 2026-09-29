<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("1")) {
    response.sendRedirect("Logout.jsp");
    return;
}

if (request.getParameter("produto") == null) {
    out.println("Produto não fornecido.");
    return;
}

int produto = Integer.parseInt(request.getParameter("produto"));

PreparedStatement psSelect = conn.prepareStatement(
    "SELECT id_produto, nome, descricao, preco, stock, id_categoria FROM produto WHERE id_produto = ?"
);
psSelect.setInt(1, produto);
ResultSet result = psSelect.executeQuery();
if (!result.next()) {
    out.println("Produto não encontrado na base de dados.");
    return;
}
Map<String, Object> dadosProduto = new HashMap<>();
dadosProduto.put("nome", result.getString("nome"));
dadosProduto.put("descricao", result.getString("descricao"));
dadosProduto.put("preco", result.getDouble("preco"));
dadosProduto.put("stock", result.getInt("stock"));
dadosProduto.put("id_categoria", result.getInt("id_categoria"));
result.close();
psSelect.close();

PreparedStatement psCat = conn.prepareStatement("SELECT * FROM categoria");
ResultSet categoria_result = psCat.executeQuery();
List<Map<String, Object>> categorias = new ArrayList<>();
while (categoria_result.next()) {
    Map<String, Object> categoria = new HashMap<>();
    categoria.put("id_categoria", categoria_result.getInt("id_categoria"));
    categoria.put("nome", categoria_result.getString("nome"));
    categorias.add(categoria);
}
categoria_result.close();
psCat.close();

List<String> erros = new ArrayList<>();
String novoNome = "";
String novaDescricao = "";
String novoPreco = "";
String novoStock = "";
String novaCategoria = "";

if ("POST".equals(request.getMethod())) {
    novoNome = request.getParameter("nome");
    novaDescricao = request.getParameter("descricao");
    double novoPrecoDouble = Double.parseDouble(request.getParameter("preco"));
    int novoStockInt = Integer.parseInt(request.getParameter("stock"));
    int novaCategoriaInt = Integer.parseInt(request.getParameter("id_categoria"));

    novoPreco = String.valueOf(novoPrecoDouble);
    novoStock = String.valueOf(novoStockInt);
    novaCategoria = String.valueOf(novaCategoriaInt);

    if (novoPrecoDouble <= 0) erros.add("O preço tem de ser maior que 0.");
    if (novoStockInt < 0)     erros.add("O stock não pode ser negativo.");

    if (erros.isEmpty()) {
        PreparedStatement psUpdate = conn.prepareStatement(
            "UPDATE produto SET nome=?, descricao=?, preco=?, stock=?, id_categoria=? WHERE id_produto=?"
        );
        psUpdate.setString(1, novoNome);
        psUpdate.setString(2, novaDescricao);
        psUpdate.setDouble(3, novoPrecoDouble);
        psUpdate.setInt(4, novoStockInt);
        psUpdate.setInt(5, novaCategoriaInt);
        psUpdate.setInt(6, produto);
        psUpdate.executeUpdate();
        psUpdate.close();
%>
        <script>alert('Produto editado com sucesso!'); window.location.href='AdminGerirProdutos.jsp';</script>
<%
    }
}
%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Editar Produto - Admin</title>
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

    .erro { background: #ffe8e8; border-left: 4px solid #f44336; padding: 10px; margin-bottom: 15px; border-radius: 4px; color: #b71c1c; }

    label { margin-top: 15px; display: block; font-weight: bold; }

    input, select, textarea {
      width: 100%;
      padding: 8px;
      margin-top: 5px;
      border-radius: 4px;
      border: 1px solid #ccc;
    }
    input:focus, select:focus, textarea:focus {
      outline: none;
      border-color: hsl(122, 39.40%, 49.20%);
      box-shadow: 0 0 0 2px rgba(76, 175, 80, 0.2);
    }

    .btn { margin-top: 20px; padding: 10px 20px; border: none; cursor: pointer; border-radius: 4px; }
    .save-btn { background-color: hsl(122, 39.40%, 49.20%); color: white; }
    .save-btn:hover { background-color: #388E3C; }
  </style>
</head>
<body>

<div class="navbar">
  <div class="nav-left">FelixUberShop - Admin</div>
  <div class="nav-right">
    <a href="AdminGerirProdutos.jsp">Voltar</a>
    <a href="Logout.jsp">Log Out</a>
  </div>
</div>

<div class="container">
  <h2>Editar Produto</h2>

  <% if (!erros.isEmpty()) { %>
  <div class="erro">
    <% for (String erro : erros) { %><%= erro %><br><% } %>
  </div>
  <% } %>

  <form method="POST">
    <label>Nome</label>
    <input type="text" name="nome" value="<%= novoNome.isEmpty() ? dadosProduto.get("nome") : novoNome %>" required>

    <label>Descrição</label>
    <textarea name="descricao" rows="3"><%= novaDescricao.isEmpty() ? dadosProduto.get("descricao") : novaDescricao %></textarea>

    <label>Categoria</label>
    <select name="id_categoria" required>
      <% for (Map<String, Object> categoria : categorias) { %>
      <option value="<%= categoria.get("id_categoria") %>"
        <%= ((Integer)categoria.get("id_categoria") == (novaCategoria.isEmpty() ? (Integer)dadosProduto.get("id_categoria") : Integer.parseInt(novaCategoria))) ? "selected" : "" %>>
        <%= categoria.get("nome") %>
      </option>
      <% } %>
    </select>

    <label>Preço (€)</label>
    <input type="number" step="0.01" name="preco" min="0.01" value="<%= novoPreco.isEmpty() ? dadosProduto.get("preco") : novoPreco %>" required>

    <label>Stock</label>
    <input type="number" name="stock" min="0" value="<%= novoStock.isEmpty() ? dadosProduto.get("stock") : novoStock %>" required>

    <button class="btn save-btn" type="submit">Guardar Alterações</button>
  </form>
</div>

</body>
</html>