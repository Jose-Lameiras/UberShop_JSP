<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("1")) {
    response.sendRedirect("Logout.jsp");
    return;
}

if (request.getParameter("eliminar") != null) {
    int idEncomenda = Integer.parseInt(request.getParameter("eliminar"));

    PreparedStatement psBusca = conn.prepareStatement("SELECT id_cliente, total FROM encomenda WHERE id_encomenda = ?");
    psBusca.setInt(1, idEncomenda);
    ResultSet rsBusca = psBusca.executeQuery();

    if (rsBusca.next()) {
        int id_cliente = rsBusca.getInt("id_cliente");
        double total = rsBusca.getDouble("total");

        PreparedStatement psReembolso = conn.prepareStatement("UPDATE carteira SET saldo = saldo + ? WHERE id_utilizador = ?");
        psReembolso.setDouble(1, total);
        psReembolso.setInt(2, id_cliente);
        psReembolso.executeUpdate();

        PreparedStatement psDesconta = conn.prepareStatement("UPDATE carteira SET saldo = saldo - ? WHERE id_utilizador = 100");
        psDesconta.setDouble(1, total);
        psDesconta.executeUpdate();

        PreparedStatement psMov = conn.prepareStatement(
            "INSERT INTO movimentos_carteira (id_utilizador_op, operacao, valor, carteira_origem, carteira_destino, id_encomenda) VALUES (?, 'reembolso', ?, 100, ?, ?)"
        );
        psMov.setInt(1, id_cliente);
        psMov.setDouble(2, total);
        psMov.setInt(3, id_cliente);
        psMov.setInt(4, idEncomenda);
        psMov.executeUpdate();

        PreparedStatement psStock = conn.prepareStatement(
            "UPDATE produto p JOIN linha_encomenda l ON p.id_produto = l.id_produto SET p.stock = p.stock + l.quantidade WHERE l.id_encomenda = ?"
        );
        psStock.setInt(1, idEncomenda);
        psStock.executeUpdate();
    }

    PreparedStatement psDelEnc = conn.prepareStatement("DELETE FROM encomenda WHERE id_encomenda = ?");
    psDelEnc.setInt(1, idEncomenda);
    psDelEnc.executeUpdate();

    response.sendRedirect("AdminGerirEncomendas.jsp");
    return;
}

String pesquisa = request.getParameter("pesquisa") != null ? request.getParameter("pesquisa").trim() : "";

String sqlEnc =
    "SELECT e.id_encomenda, e.codigo_validacao, e.data_encomenda, e.total, " +
    "u.nomeUtilizador AS cliente, p.nome AS produto, l.quantidade " +
    "FROM encomenda e " +
    "JOIN utilizador u ON e.id_cliente = u.id_utilizador " +
    "JOIN linha_encomenda l ON e.id_encomenda = l.id_encomenda " +
    "JOIN produto p ON l.id_produto = p.id_produto " +
    (!pesquisa.isEmpty() ? "WHERE u.nomeUtilizador LIKE ? " : "") +
    "ORDER BY e.id_encomenda";

PreparedStatement psEnc = conn.prepareStatement(sqlEnc);
if (!pesquisa.isEmpty()) psEnc.setString(1, "%" + pesquisa + "%");
ResultSet rsEnc = psEnc.executeQuery();

List<Map<String, Object>> encomendas = new ArrayList<>();
while (rsEnc.next()) {
    Map<String, Object> e = new HashMap<>();
    e.put("id_encomenda", rsEnc.getInt("id_encomenda"));
    e.put("codigo", rsEnc.getString("codigo_validacao"));
    e.put("data", rsEnc.getString("data_encomenda"));
    e.put("total", String.format("%.2f", rsEnc.getDouble("total")));
    e.put("cliente", rsEnc.getString("cliente"));
    e.put("produto", rsEnc.getString("produto"));
    e.put("quantidade", rsEnc.getInt("quantidade"));
    encomendas.add(e);
}
rsEnc.close();
psEnc.close();
%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Gerir Encomendas - Admin</title>
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

    .pesquisa-box {
      display: flex;
      gap: 10px;
      margin-bottom: 20px;
    }
    .pesquisa-box input {
      flex: 1;
      padding: 8px;
      border: 1px solid #ccc;
      border-radius: 4px;
    }

    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th, td { border: 1px solid #ccc; padding: 10px; text-align: center; }
    th { background-color: hsl(122, 39.40%, 49.20%); color: white; }

    .btn { padding: 6px 14px; border: none; border-radius: 4px; cursor: pointer; }
    .eliminar-btn { background-color: #f44336; color: white; }
    .eliminar-btn:hover { background-color: #c62828; }
    .pesquisa-btn { background-color: hsl(122, 39.40%, 49.20%); color: white; }
    .pesquisa-btn:hover { background-color: #388E3C; }
    .limpar-btn { background-color: #888; color: white; }
    .limpar-btn:hover { background-color: #555; }
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
  <h2>Gerir Encomendas</h2>

  <form method="get" class="pesquisa-box">
    <input type="text" name="pesquisa" placeholder="Pesquisar por cliente..." value="<%= pesquisa %>">
    <button class="btn pesquisa-btn" type="submit">Pesquisar</button>
    <a href="AdminGerirEncomendas.jsp"><button class="btn limpar-btn" type="button">Limpar</button></a>
  </form>

  <table>
    <tr>
      <th>Nº</th>
      <th>Código</th>
      <th>Cliente</th>
      <th>Produto</th>
      <th>Qtd</th>
      <th>Data</th>
      <th>Total</th>
      <th>Eliminar</th>
    </tr>
    <% for (Map<String, Object> encomenda : encomendas) { %>
    <tr>
      <td><%= encomenda.get("id_encomenda") %></td>
      <td><%= encomenda.get("codigo") %></td>
      <td><%= encomenda.get("cliente") %></td>
      <td><%= encomenda.get("produto") %></td>
      <td><%= encomenda.get("quantidade") %></td>
      <td><%= encomenda.get("data") %></td>
      <td><%= encomenda.get("total") %> €</td>
      <td>
        <form method="post" style="margin:0;">
          <button class="btn eliminar-btn" type="submit" name="eliminar" value="<%= encomenda.get("id_encomenda") %>">Eliminar</button>
        </form>
      </td>
    </tr>
    <% } %>
  </table>
</div>

</body>
</html>
