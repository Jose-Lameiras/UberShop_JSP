<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("1")) {
    response.sendRedirect("Logout.jsp");
    return;
}

String erro = null;

if ("POST".equals(request.getMethod())) {
    String nome      = request.getParameter("nome");
    String descricao = request.getParameter("descricao");
    String categoria = request.getParameter("categoria");
    double preco     = Double.parseDouble(request.getParameter("preco"));
    int stock        = Integer.parseInt(request.getParameter("stock"));

    if (preco <= 0) {
        erro = "O preço tem de ser maior que 0.";
    } else if (stock < 0) {
        erro = "O stock não pode ser negativo.";
    } else {
        PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO produto (nome, descricao, preco, stock, categoria, ativo) VALUES (?, ?, ?, ?, ?, 1)"
        );
        ps.setString(1, nome);
        ps.setString(2, descricao);
        ps.setDouble(3, preco);
        ps.setInt(4, stock);
        ps.setString(5, categoria);
        ps.executeUpdate();
        ps.close();
        response.sendRedirect("AdminGerirProdutos.jsp");
        return;
    }
}

PreparedStatement psCat = conn.prepareStatement("SELECT DISTINCT categoria FROM produto ORDER BY categoria");
ResultSet rsCat = psCat.executeQuery();
List<String> categorias = new ArrayList<>();
while (rsCat.next()) {
    categorias.add(rsCat.getString("categoria"));
}
rsCat.close();
psCat.close();
%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Adicionar Produto - Admin</title>
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
      max-width: 500px;
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

    .erro {
      background: #ffe8e8;
      border-left: 4px solid #f44336;
      padding: 10px;
      margin-bottom: 15px;
      border-radius: 4px;
    }

    label {
      margin-top: 15px;
      display: block;
      font-weight: bold;
    }

    input, select, textarea {
      width: 100%;
      padding: 8px;
      margin-top: 5px;
      border-radius: 4px;
      border: 1px solid #ccc;
    }

    .btn {
      margin-top: 20px;
      padding: 10px 20px;
      border: none;
      cursor: pointer;
      border-radius: 4px;
    }
    .save-btn {
      background-color: hsl(122, 39.40%, 49.20%);
      color: white;
    }
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
    <h2>Adicionar Novo Produto</h2>

    <% if (erro != null) { %>
    <div class="erro"><%= erro %></div>
    <% } %>

    <form method="POST">
      <label>Nome</label>
      <input type="text" name="nome" required>

      <label>Descrição</label>
      <textarea name="descricao" rows="3"></textarea>

      <label>Categoria</label>
      <input type="text" name="categoria" list="lista_categorias" required>
      <datalist id="lista_categorias">
        <% for (String cat : categorias) { %>
        <option value="<%= cat %>">
        <% } %>
      </datalist>

      <label>Preço (€)</label>
      <input type="number" step="0.01" name="preco" min="0.01" required>

      <label>Stock</label>
      <input type="number" name="stock" min="0" required>

      <button class="btn save-btn" type="submit">Adicionar Produto</button>
    </form>
  </div>

</body>
</html>
