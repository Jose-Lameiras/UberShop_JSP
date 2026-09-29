<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("2")) {
    response.sendRedirect("login.jsp");
    return;
}

int id_utilizador = (Integer) session.getAttribute("id_utilizador");
String mensagem = "";
boolean isErro = false;

if (request.getParameter("apagar_encomenda") != null) {
    int id_encomenda = Integer.parseInt(request.getParameter("id_encomenda"));

    PreparedStatement psEnc = conn.prepareStatement(
        "SELECT e.total, l.id_produto, l.quantidade " +
        "FROM encomenda e " +
        "JOIN linha_encomenda l ON e.id_encomenda = l.id_encomenda " +
        "WHERE e.id_encomenda = ? AND e.id_cliente = ?"
    );
    psEnc.setInt(1, id_encomenda);
    psEnc.setInt(2, id_utilizador);
    ResultSet rsEnc = psEnc.executeQuery();

    if (rsEnc.next()) {
        double total = rsEnc.getDouble("total");
        int id_produto = rsEnc.getInt("id_produto");
        int quantidade = rsEnc.getInt("quantidade");

        PreparedStatement psStock = conn.prepareStatement("UPDATE produto SET stock = stock + ? WHERE id_produto = ?");
        psStock.setInt(1, quantidade);
        psStock.setInt(2, id_produto);
        psStock.executeUpdate();

        PreparedStatement psDevolver = conn.prepareStatement("UPDATE carteira SET saldo = saldo + ? WHERE id_utilizador = ?");
        psDevolver.setDouble(1, total);
        psDevolver.setInt(2, id_utilizador);
        psDevolver.executeUpdate();

        PreparedStatement psDescontar = conn.prepareStatement("UPDATE carteira SET saldo = saldo - ? WHERE id_utilizador = 100");
        psDescontar.setDouble(1, total);
        psDescontar.executeUpdate();

        PreparedStatement psMov = conn.prepareStatement(
            "INSERT INTO movimentos_carteira (id_utilizador_op, operacao, valor, carteira_origem, carteira_destino, id_encomenda) VALUES (?, 'reembolso', ?, 100, ?, ?)"
        );
        psMov.setInt(1, id_utilizador);
        psMov.setDouble(2, total);
        psMov.setInt(3, id_utilizador);
        psMov.setInt(4, id_encomenda);
        psMov.executeUpdate();

        PreparedStatement psApagar = conn.prepareStatement("DELETE FROM encomenda WHERE id_encomenda = ? AND id_cliente = ?");
        psApagar.setInt(1, id_encomenda);
        psApagar.setInt(2, id_utilizador);
        psApagar.executeUpdate();

        mensagem = "Encomenda cancelada e " + total + " € devolvido à sua carteira!";
    } else {
        mensagem = "Encomenda não encontrada ou não pode ser cancelada.";
        isErro = true;
    }
}

PreparedStatement psEncomendas = conn.prepareStatement(
    "SELECT e.id_encomenda, e.codigo_validacao, e.data_encomenda, e.total, " +
    "p.nome AS produto, l.quantidade " +
    "FROM encomenda e " +
    "JOIN linha_encomenda l ON e.id_encomenda = l.id_encomenda " +
    "JOIN produto p ON l.id_produto = p.id_produto " +
    "WHERE e.id_cliente = ? " +
    "ORDER BY e.data_encomenda DESC"
);
psEncomendas.setInt(1, id_utilizador);
ResultSet rsEncomendas = psEncomendas.executeQuery();

List<Map<String, Object>> encomendas = new ArrayList<>();
while (rsEncomendas.next()) {
    Map<String, Object> e = new HashMap<>();
    e.put("id_encomenda", rsEncomendas.getInt("id_encomenda"));
    e.put("codigo", rsEncomendas.getString("codigo_validacao"));
    e.put("data", rsEncomendas.getString("data_encomenda"));
    e.put("total", rsEncomendas.getDouble("total"));
    e.put("produto", rsEncomendas.getString("produto"));
    e.put("quantidade", rsEncomendas.getInt("quantidade"));
    encomendas.add(e);
}

String classeMensagem = isErro ? "erro" : "mensagem";
%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Encomendas</title>
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
      max-width: 1000px;
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

    .mensagem { padding: 10px; background: #e8f5e9; border-left: 4px solid #4CAF50; margin-bottom: 15px; border-radius: 4px; }
    .erro     { padding: 10px; background: #ffe8e8; border-left: 4px solid #f44336; margin-bottom: 15px; border-radius: 4px; }

    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th, td { border: 1px solid #ccc; padding: 10px; text-align: center; }
    th { background-color: hsl(122, 39.40%, 49.20%); color: white; }

    .btn { padding: 6px 14px; border: none; border-radius: 4px; cursor: pointer; }
    .cancelar-btn { background-color: #f44336; color: white; }
    .cancelar-btn:hover { background-color: #c62828; }
  </style>
</head>

<body>

<div class="navbar">
  <div class="nav-left">FelixUberShop</div>
  <div class="nav-right">
    <a href="PagIniCliente.jsp">Voltar</a>
    <a href="Logout.jsp">Log Out</a>
  </div>
</div>

<div class="container">
  <h2>As Minhas Encomendas</h2>

  <div class="<%= classeMensagem %>" <%= mensagem.isEmpty() ? "style='display:none'" : "" %>><%= mensagem %></div>

  <table>
    <tr>
      <th>Código</th>
      <th>Data</th>
      <th>Produto</th>
      <th>Quantidade</th>
      <th>Total</th>
      <th>Cancelar</th>
    </tr>
    <% for (Map<String, Object> e : encomendas) { %>
      <tr>
        <td><%= e.get("codigo") %></td>
        <td><%= e.get("data") %></td>
        <td><%= e.get("produto") %></td>
        <td><%= e.get("quantidade") %></td>
        <td><%= e.get("total") %> €</td>
        <td>
          <form method="post" style="margin:0;">
            <input type="hidden" name="id_encomenda" value="<%= e.get("id_encomenda") %>">
            <button type="submit" name="apagar_encomenda" class="btn cancelar-btn">Cancelar</button>
          </form>
        </td>
      </tr>
    <% } %>
  </table>
</div>

</body>
</html>
