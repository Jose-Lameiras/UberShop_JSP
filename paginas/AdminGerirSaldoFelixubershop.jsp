<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("1")) {
    response.sendRedirect("Logout.jsp");
    return;
}

int id_utilizador = 100;

PreparedStatement psSaldo = conn.prepareStatement("SELECT saldo FROM carteira WHERE id_utilizador = ?");
psSaldo.setInt(1, id_utilizador);
ResultSet rsSaldo = psSaldo.executeQuery();
double saldo = 0;
if (rsSaldo.next()) {
    saldo = rsSaldo.getDouble("saldo");
}
rsSaldo.close();
psSaldo.close();

PreparedStatement psMov = conn.prepareStatement(
    "SELECT m.id_movimento, m.operacao, m.valor, m.data_operacao, " +
    "m.carteira_origem, m.carteira_destino, m.id_encomenda, " +
    "u.nomeUtilizador AS quem_op, " +
    "uo.mail AS mail_origem, " +
    "ud.mail AS mail_destino " +
    "FROM movimentos_carteira m " +
    "LEFT JOIN utilizador u ON m.id_utilizador_op = u.id_utilizador " +
    "LEFT JOIN utilizador uo ON m.carteira_origem = uo.id_utilizador " +
    "LEFT JOIN utilizador ud ON m.carteira_destino = ud.id_utilizador " +
    "WHERE m.carteira_origem = ? OR m.carteira_destino = ? " +
    "ORDER BY m.data_operacao DESC"
);
psMov.setInt(1, id_utilizador);
psMov.setInt(2, id_utilizador);
ResultSet rsMov = psMov.executeQuery();

List<Map<String, String>> movimentos = new ArrayList<>();
while (rsMov.next()) {
    boolean entrada = (rsMov.getInt("carteira_destino") == id_utilizador);
    double valor = rsMov.getDouble("valor");
    int idEncomenda = rsMov.getInt("id_encomenda");
    String mailOrigem = rsMov.getString("mail_origem");
    String mailDestino = rsMov.getString("mail_destino");
    String quemOp = rsMov.getString("quem_op");

    Map<String, String> row = new LinkedHashMap<>();
    row.put("id", String.valueOf(rsMov.getInt("id_movimento")));
    row.put("operacao", rsMov.getString("operacao"));
    row.put("valorFormatado", (entrada ? "+" : "-") + String.format("%.2f", valor) + " €");
    row.put("classe", entrada ? "entrada" : "saida");
    row.put("data", rsMov.getString("data_operacao"));
    row.put("mailOrigem", mailOrigem == null ? "-" : mailOrigem);
    row.put("mailDestino", mailDestino == null ? "-" : mailDestino);
    row.put("encomenda", idEncomenda == 0 ? "-" : String.valueOf(idEncomenda));
    row.put("quemOp", quemOp == null ? "-" : quemOp);
    movimentos.add(row);
}
rsMov.close();
psMov.close();

String saldoFormatado = String.format("%.2f", saldo);
%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Carteira FelixUberShop - Admin</title>
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
      max-width: 1200px;
      background: white;
      padding: 30px;
      border-radius: 10px;
      box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
      overflow-x: auto;
    }

    h2 { text-align: center; color: #333; margin-bottom: 20px; }

    .saldo-box {
      text-align: center;
      font-size: 20px;
      color: hsl(122, 39%, 35%);
      margin-bottom: 25px;
    }

    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th, td { border: 1px solid #ccc; padding: 10px; text-align: center; }
    th { background-color: hsl(122, 39.40%, 49.20%); color: white; }

    .entrada { color: #2e7d32; font-weight: bold; }
    .saida   { color: #c62828; font-weight: bold; }
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
    <h2>Carteira FelixUberShop</h2>

    <div class="saldo-box">
      <strong>Saldo atual:</strong> <%= saldoFormatado %> €
    </div>

    <h2>Histórico de Movimentos</h2>
    <table>
      <tr>
        <th>Nº</th>
        <th>Operação</th>
        <th>Valor</th>
        <th>Data</th>
        <th>Email Origem</th>
        <th>Email Destino</th>
        <th>Encomenda</th>
        <th>Realizado por</th>
      </tr>
      <% for (Map<String, String> m : movimentos) { %>
      <tr>
        <td><%= m.get("id") %></td>
        <td><%= m.get("operacao") %></td>
        <td class="<%= m.get("classe") %>"><%= m.get("valorFormatado") %></td>
        <td><%= m.get("data") %></td>
        <td><%= m.get("mailOrigem") %></td>
        <td><%= m.get("mailDestino") %></td>
        <td><%= m.get("encomenda") %></td>
        <td><%= m.get("quemOp") %></td>
      </tr>
      <% } %>
    </table>
  </div>

</body>
</html>