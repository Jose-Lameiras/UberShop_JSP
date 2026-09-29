<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("id_utilizador") != null) {
    response.sendRedirect("Logout.jsp");
}

List<String> categorias = new ArrayList<>();
PreparedStatement psCat = conn.prepareStatement(
    "SELECT DISTINCT categoria FROM produto WHERE ativo = 1 ORDER BY categoria"
);
ResultSet categoria_result = psCat.executeQuery();
while (categoria_result.next()) {
    categorias.add(categoria_result.getString("categoria"));
}
categoria_result.close();
psCat.close();

List<Map<String, Object>> promocoes = new ArrayList<>();
PreparedStatement psPromo = conn.prepareStatement(
    "SELECT titulo, mensagem, data_inicio, data_fim FROM promocao " +
    "WHERE ativo = 1 " +
    "AND (data_inicio IS NULL OR data_inicio <= CURDATE()) " +
    "AND (data_fim IS NULL OR data_fim >= CURDATE()) " +
    "ORDER BY id_promocao DESC"
);
ResultSet promo_result = psPromo.executeQuery();
while (promo_result.next()) {
    Map<String, Object> promocao = new HashMap<>();
    promocao.put("titulo", promo_result.getString("titulo"));
    promocao.put("mensagem", promo_result.getString("mensagem"));
    promocoes.add(promocao);
}
promo_result.close();
psPromo.close();

if ("POST".equals(request.getMethod())) {
    String categoria_escolhida = request.getParameter("categoria");
    if (categoria_escolhida == null || categoria_escolhida.isEmpty()) {
%>
        <script>alert('Selecione uma categoria válida.');</script>
<%
    } else {
        PreparedStatement psCheck = conn.prepareStatement(
            "SELECT id_produto FROM produto WHERE categoria = ? AND ativo = 1 AND stock > 0 LIMIT 1"
        );
        psCheck.setString(1, categoria_escolhida);
        ResultSet result = psCheck.executeQuery();
        if (result.next()) {
            response.sendRedirect("MostrarProdutos.jsp?categoria=" + java.net.URLEncoder.encode(categoria_escolhida, "UTF-8"));
        } else {
%>
            <script>alert('Não encontrámos nenhum produto disponível para essa categoria.');</script>
<%
        }
        result.close();
        psCheck.close();
    }
}
%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>FelixUberShop</title>
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
      margin: 30px auto;
      width: 90%;
      max-width: 400px;
      background: white;
      padding: 30px;
      border-radius: 10px;
      box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
    }

    h2 { text-align: center; color: #333; margin-bottom: 20px; }

    label { display: block; margin-bottom: 5px; font-weight: bold; }

    select {
      width: 100%;
      padding: 8px;
      border: 1px solid #ccc;
      border-radius: 5px;
    }

    button[type="submit"] {
      width: 100%;
      padding: 10px;
      margin-top: 15px;
      font-size: 16px;
      border: none;
      border-radius: 5px;
      cursor: pointer;
      background-color: hsl(122, 39.40%, 49.20%);
      color: white;
    }
    button[type="submit"]:hover { background-color: #388E3C; }

    .promocoes {
      width: 90%;
      max-width: 900px;
      margin: 10px auto 30px auto;
    }
    .promocoes h2 { color: hsl(122, 39%, 35%); margin-bottom: 15px; text-align: left; }
    .promocoes-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
      gap: 15px;
    }
    .promocao-card {
      background: white;
      border-left: 4px solid hsl(122, 39%, 49%);
      padding: 15px;
      border-radius: 6px;
      box-shadow: 0 2px 6px rgba(0, 0, 0, 0.06);
    }
    .promocao-card h3 { color: hsl(122, 39%, 35%); margin-bottom: 8px; font-size: 16px; }
    .promocao-card p { font-size: 14px; line-height: 1.4; }
  </style>
</head>
<body>

  <div class="navbar">
    <div class="nav-left">FelixUberShop</div>
    <div class="nav-right">
      <a href="login.jsp">Login</a>
      <a href="registo.jsp">Registar</a>
      <a href="contactos.jsp">Contactos</a>
    </div>
  </div>

  <div class="container">
    <h2>Bem-vindo</h2>
    <form method="POST">
      <label>Categoria</label>
      <select name="categoria" required>
        <% for (String categoria : categorias) { %>
          <option value="<%= categoria %>"><%= categoria %></option>
        <% } %>
      </select>
      <button type="submit">Procurar Produtos</button>
    </form>
  </div>

  <% if (!promocoes.isEmpty()) { %>
  <div class="promocoes">
    <h2>Promoções e Informações</h2>
    <div class="promocoes-grid">
      <% for (Map<String, Object> promocao : promocoes) { %>
        <div class="promocao-card">
          <h3><%= promocao.get("titulo") %></h3>
          <p><%= promocao.get("mensagem") %></p>
        </div>
      <% } %>
    </div>
  </div>
  <% } %>

</body>
</html>