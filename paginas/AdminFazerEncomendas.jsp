<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("1")) {
    response.sendRedirect("Logout.jsp");
    return;
}

int id_admin = (Integer) session.getAttribute("id_utilizador");
String mensagem = "";
boolean isErro = false;

if ("POST".equals(request.getMethod()) && request.getParameter("comprar") != null) {
    String nomeCliente = request.getParameter("nome_cliente") != null ? request.getParameter("nome_cliente").trim() : "";
    if (nomeCliente.isEmpty()) {
        mensagem = "Escreva o nome do cliente antes de comprar.";
        isErro = true;
    }
    int id_cliente = 0;
    if (!isErro) {
        PreparedStatement psBusca = conn.prepareStatement("SELECT id_utilizador FROM utilizador WHERE nomeUtilizador = ? AND tipoUtilizador = 2");
        psBusca.setString(1, nomeCliente);
        ResultSet rsBusca = psBusca.executeQuery();
        if (rsBusca.next()) {
            id_cliente = rsBusca.getInt("id_utilizador");
        } else {
            mensagem = "Cliente '" + nomeCliente + "' não encontrado.";
            isErro = true;
        }
    }
    if (!isErro) {
        int id_produto = Integer.parseInt(request.getParameter("comprar"));
        String qtdParam = request.getParameter("qtd_" + id_produto);
        int quantidade = (qtdParam != null && !qtdParam.isEmpty()) ? Integer.parseInt(qtdParam) : 1;

        PreparedStatement psP = conn.prepareStatement("SELECT * FROM produto WHERE id_produto = ? AND stock >= ?");
        psP.setInt(1, id_produto);
        psP.setInt(2, quantidade);
        ResultSet rsP = psP.executeQuery();

        if (rsP.next()) {
            double preco = rsP.getDouble("preco");
            double total = preco * quantidade;

            PreparedStatement psS = conn.prepareStatement("SELECT saldo FROM carteira WHERE id_utilizador = ?");
            psS.setInt(1, id_cliente);
            ResultSet rsS = psS.executeQuery();
            double saldo = rsS.next() ? rsS.getDouble("saldo") : 0;

            if (saldo >= total) {
                PreparedStatement psDesconta = conn.prepareStatement("UPDATE carteira SET saldo = saldo - ? WHERE id_utilizador = ?");
                psDesconta.setDouble(1, total);
                psDesconta.setInt(2, id_cliente);
                psDesconta.executeUpdate();

                PreparedStatement psCredita = conn.prepareStatement("UPDATE carteira SET saldo = saldo + ? WHERE id_utilizador = 100");
                psCredita.setDouble(1, total);
                psCredita.executeUpdate();

                String codigo = "FUS-" + new java.util.Date().getTime();

                PreparedStatement psEnc = conn.prepareStatement(
                    "INSERT INTO encomenda (codigo_validacao, id_cliente, total) VALUES (?, ?, ?)",
                    Statement.RETURN_GENERATED_KEYS
                );
                psEnc.setString(1, codigo);
                psEnc.setInt(2, id_cliente);
                psEnc.setDouble(3, total);
                psEnc.executeUpdate();

                ResultSet rsId = psEnc.getGeneratedKeys();
                int id_encomenda = rsId.next() ? rsId.getInt(1) : 0;

                PreparedStatement psLinha = conn.prepareStatement(
                    "INSERT INTO linha_encomenda (id_encomenda, id_produto, quantidade, preco_unitario) VALUES (?, ?, ?, ?)"
                );
                psLinha.setInt(1, id_encomenda);
                psLinha.setInt(2, id_produto);
                psLinha.setInt(3, quantidade);
                psLinha.setDouble(4, preco);
                psLinha.executeUpdate();

                PreparedStatement psMov = conn.prepareStatement(
                    "INSERT INTO movimentos_carteira (id_utilizador_op, operacao, valor, carteira_origem, carteira_destino, id_encomenda) VALUES (?, 'pagamento_encomenda', ?, ?, 100, ?)"
                );
                psMov.setInt(1, id_admin);
                psMov.setDouble(2, total);
                psMov.setInt(3, id_cliente);
                psMov.setInt(4, id_encomenda);
                psMov.executeUpdate();

                PreparedStatement psStock = conn.prepareStatement("UPDATE produto SET stock = stock - ? WHERE id_produto = ?");
                psStock.setInt(1, quantidade);
                psStock.setInt(2, id_produto);
                psStock.executeUpdate();

                mensagem = "Encomenda criada para o cliente! Código: " + codigo;
            } else {
                mensagem = "Saldo insuficiente do cliente.";
                isErro = true;
            }
        } else {
            mensagem = "Produto indisponível ou stock insuficiente.";
            isErro = true;
        }
    }
}

// Ordenação
String ordem = request.getParameter("ordem");
String orderBy = "id_produto";
if ("nome_asc".equals(ordem))   orderBy = "nome ASC";
if ("nome_desc".equals(ordem))  orderBy = "nome DESC";
if ("preco_asc".equals(ordem))  orderBy = "preco ASC";
if ("preco_desc".equals(ordem)) orderBy = "preco DESC";
if ("stock_asc".equals(ordem))  orderBy = "stock ASC";
if ("stock_desc".equals(ordem)) orderBy = "stock DESC";

PreparedStatement psProd = conn.prepareStatement(
    "SELECT id_produto, nome, categoria, preco, stock FROM produto WHERE stock > 0 AND ativo = 1 ORDER BY " + orderBy
);
ResultSet rsProd = psProd.executeQuery();
List<Map<String, Object>> produtos = new ArrayList<>();
while (rsProd.next()) {
    Map<String, Object> p = new HashMap<>();
    p.put("id", rsProd.getInt("id_produto"));
    p.put("nome", rsProd.getString("nome"));
    p.put("categoria", rsProd.getString("categoria"));
    p.put("preco", rsProd.getDouble("preco"));
    p.put("stock", rsProd.getInt("stock"));
    produtos.add(p);
}

String classeMensagem = isErro ? "erro" : "mensagem";
String nomeClienteForm = request.getParameter("nome_cliente") != null ? request.getParameter("nome_cliente") : "";
%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Fazer Encomenda - Admin</title>
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

    .mensagem { padding: 10px; background: #e8f5e9; border-left: 4px solid #4CAF50; margin-bottom: 15px; border-radius: 4px; }
    .erro     { padding: 10px; background: #ffe8e8; border-left: 4px solid #f44336; margin-bottom: 15px; border-radius: 4px; }

    .campo-cliente {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 20px;
    }
    .campo-cliente label { font-weight: bold; white-space: nowrap; }
    .campo-cliente input {
      padding: 8px;
      border-radius: 4px;
      border: 1px solid #ccc;
      flex: 1;
      max-width: 300px;
    }

    .ordenar { margin: 10px 0 15px; text-align: right; }
    .ordenar select { padding: 5px; border-radius: 4px; }

    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th, td { border: 1px solid #ccc; padding: 10px; text-align: center; }
    th { background-color: hsl(122, 39.40%, 49.20%); color: white; }

    .comprar-btn {
      padding: 6px 14px;
      background: hsl(122, 39.40%, 49.20%);
      color: white;
      border: none;
      border-radius: 6px;
      cursor: pointer;
    }
    .comprar-btn:hover { background: #388E3C; }

    input[type="number"] { width: 60px; padding: 4px; border: 1px solid #ccc; border-radius: 4px; text-align: center; }
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
  <h2>Fazer Encomenda</h2>

  <div class="<%= classeMensagem %>" <%= mensagem.isEmpty() ? "style='display:none'" : "" %>><%= mensagem %></div>

  <form method="post">
    <div class="campo-cliente">
      <label>1. Nome do cliente:</label>
      <input type="text" name="nome_cliente" placeholder="Nome do cliente..." value="<%= nomeClienteForm %>" required>
    </div>

    <div style="font-weight: bold; margin-bottom: 8px;">2. Escolher o produto:</div>

    <div class="ordenar">
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
    </div>

    <table>
      <tr>
        <th>Nº</th>
        <th>Produto</th>
        <th>Categoria</th>
        <th>Preço</th>
        <th>Stock</th>
        <th>Quantidade</th>
        <th>Comprar</th>
      </tr>
      <% for (Map<String, Object> p : produtos) { %>
        <tr>
          <td><%= p.get("id") %></td>
          <td><%= p.get("nome") %></td>
          <td><%= p.get("categoria") %></td>
          <td><%= p.get("preco") %> €</td>
          <td><%= p.get("stock") %></td>
          <td><input type="number" name="qtd_<%= p.get("id") %>" value="1" min="1" max="<%= p.get("stock") %>"></td>
          <td><button class="comprar-btn" type="submit" name="comprar" value="<%= p.get("id") %>">Comprar</button></td>
        </tr>
      <% } %>
    </table>
  </form>
</div>

</body>
</html>
