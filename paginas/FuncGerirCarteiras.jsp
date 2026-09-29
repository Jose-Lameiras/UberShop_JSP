<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("3")) {
    response.sendRedirect("Logout.jsp");
    return;
}

int id_funcionario = (Integer) session.getAttribute("id_utilizador");
String mensagem = "";
boolean isErro = false;

if (request.getParameter("adicionar") != null) {
    int id_cliente = Integer.parseInt(request.getParameter("id_cliente"));
    double valor = Double.parseDouble(request.getParameter("valor"));
    if (valor > 0) {
        PreparedStatement psAdd = conn.prepareStatement("UPDATE carteira SET saldo = saldo + ? WHERE id_utilizador = ?");
        psAdd.setDouble(1, valor);
        psAdd.setInt(2, id_cliente);
        psAdd.executeUpdate();

        PreparedStatement psMov = conn.prepareStatement(
            "INSERT INTO movimentos_carteira (id_utilizador_op, operacao, valor, carteira_destino) VALUES (?, 'adicionar', ?, ?)"
        );
        psMov.setInt(1, id_funcionario);
        psMov.setDouble(2, valor);
        psMov.setInt(3, id_cliente);
        psMov.executeUpdate();

        mensagem = "Adicionado " + valor + " € à carteira do cliente #" + id_cliente;
    }
}

if (request.getParameter("levantar") != null) {
    int id_cliente = Integer.parseInt(request.getParameter("id_cliente"));
    double valor = Double.parseDouble(request.getParameter("valor"));
    if (valor > 0) {
        PreparedStatement psSaldo = conn.prepareStatement("SELECT saldo FROM carteira WHERE id_utilizador = ?");
        psSaldo.setInt(1, id_cliente);
        ResultSet rsSaldo = psSaldo.executeQuery();

        if (rsSaldo.next() && rsSaldo.getDouble("saldo") >= valor) {
            PreparedStatement psLev = conn.prepareStatement("UPDATE carteira SET saldo = saldo - ? WHERE id_utilizador = ?");
            psLev.setDouble(1, valor);
            psLev.setInt(2, id_cliente);
            psLev.executeUpdate();

            PreparedStatement psMov = conn.prepareStatement(
                "INSERT INTO movimentos_carteira (id_utilizador_op, operacao, valor, carteira_origem) VALUES (?, 'levantar', ?, ?)"
            );
            psMov.setInt(1, id_funcionario);
            psMov.setDouble(2, valor);
            psMov.setInt(3, id_cliente);
            psMov.executeUpdate();

            mensagem = "Levantado " + valor + " € da carteira do cliente #" + id_cliente;
        } else {
            mensagem = "Saldo insuficiente para levantar.";
            isErro = true;
        }
    }
}

PreparedStatement psCarteiras = conn.prepareStatement(
    "SELECT c.id_carteira, c.id_utilizador, c.saldo, u.nomeUtilizador, u.mail " +
    "FROM carteira c " +
    "JOIN utilizador u ON c.id_utilizador = u.id_utilizador " +
    "WHERE u.tipoUtilizador = 2 " +
    "ORDER BY c.id_carteira"
);
ResultSet rsCarteiras = psCarteiras.executeQuery();
List<Map<String, Object>> listaCarteiras = new ArrayList<>();
while (rsCarteiras.next()) {
    Map<String, Object> c = new HashMap<>();
    c.put("id_carteira", rsCarteiras.getInt("id_carteira"));
    c.put("id_utilizador", rsCarteiras.getInt("id_utilizador"));
    c.put("saldo", rsCarteiras.getDouble("saldo"));
    c.put("nomeUtilizador", rsCarteiras.getString("nomeUtilizador"));
    c.put("mail", rsCarteiras.getString("mail"));
    listaCarteiras.add(c);
}

String classeMensagem = isErro ? "erro" : "mensagem";
%>
<!DOCTYPE html>
<html lang="pt">

<head>
  <meta charset="UTF-8">
  <title>Gerir Carteiras - Funcionário</title>
  <style>
    *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: Arial, sans-serif;
      background-color: #f4f4f4;
      display: flex; flex-direction: column; align-items: center;
      padding-top: 100px; min-height: 100vh;
    }

    .navbar {
      position: fixed; top: 0; left: 0; width: 100%;
      background-color: hsl(122, 39.40%, 49.20%); color: white;
      display: flex; justify-content: space-between; align-items: center;
      padding: 15px 30px; box-shadow: 0 2px 8px rgba(0,0,0,0.2); z-index: 1000;
    }
    .navbar a { color: white; text-decoration: none; margin-left: 20px; font-weight: bold; }
    .navbar a:hover { text-decoration: underline; }

    .content { padding: 20px; width: 100%; max-width: 1100px; }

    .mensagem { padding: 10px; background: #e8f5e9; border-left: 4px solid #4CAF50; margin-bottom: 15px; border-radius: 4px; }
    .erro { padding: 10px; background: #ffe8e8; border-left: 4px solid #f44336; margin-bottom: 15px; border-radius: 4px; }

    table { width: 100%; border-collapse: collapse; margin-top: 20px; background: white; }
    th, td { border: 1px solid #ccc; padding: 10px; text-align: left; vertical-align: middle; }
    th { background-color: #f4f4f4; }

    .acoes-form { display: flex; gap: 6px; align-items: center; }
    .acoes-form input[type="number"] { width: 80px; padding: 4px; border: 1px solid #ccc; border-radius: 4px; }

    .btn { padding: 5px 10px; border: none; border-radius: 4px; cursor: pointer; }
    .add-btn { background-color: #4CAF50; color: white; }
    .lev-btn { background-color: #f44336; color: white; }
  </style>
</head>

<body>

<div class="navbar">
  <div class="nav-left">Gerir Carteiras - Funcionário</div>
  <div class="nav-right">
    <a href="PagIniFuncionario.jsp">Voltar</a>
    <a href="Logout.jsp">Log Out</a>
  </div>
</div>

<div class="content">

  <div class="<%= classeMensagem %>" <%= mensagem.isEmpty() ? "style='display:none'" : "" %>><%= mensagem %></div>

  <table>
    <tr>
      <th>Id Carteira</th>
      <th>Cliente</th>
      <th>Email</th>
      <th>Saldo</th>
      <th>Adicionar</th>
      <th>Levantar</th>
    </tr>
    <% for (Map<String, Object> c : listaCarteiras) { %>
      <tr>
        <td><%= c.get("id_carteira") %></td>
        <td><%= c.get("nomeUtilizador") %></td>
        <td><%= c.get("mail") %></td>
        <td><%= String.format("%.2f", (Double) c.get("saldo")) %> €</td>
        <td>
          <form method="get" class="acoes-form">
            <input type="hidden" name="id_cliente" value="<%= c.get("id_utilizador") %>">
            <input type="number" step="0.01" name="valor" min="0.01" required>
            <button type="submit" name="adicionar" class="btn add-btn">+</button>
          </form>
        </td>
        <td>
          <form method="get" class="acoes-form">
            <input type="hidden" name="id_cliente" value="<%= c.get("id_utilizador") %>">
            <input type="number" step="0.01" name="valor" min="0.01" required>
            <button type="submit" name="levantar" class="btn lev-btn">-</button>
          </form>
        </td>
      </tr>
    <% } %>
  </table>

</div>

</body>
</html>
