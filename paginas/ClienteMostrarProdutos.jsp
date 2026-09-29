<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("2")) {
    response.sendRedirect("Logout.jsp");
    return;
}

int id_utilizador = (Integer) session.getAttribute("id_utilizador");
String mensagem = "";
boolean isErro = false;

if ("POST".equals(request.getMethod()) && request.getParameter("comprar") != null) {
    int id_produto = Integer.parseInt(request.getParameter("id_produto"));
    int quantidade = Integer.parseInt(request.getParameter("quantidade"));

    PreparedStatement psProd = conn.prepareStatement("SELECT preco, stock FROM produto WHERE id_produto = ?");
    psProd.setInt(1, id_produto);
    ResultSet rsProd = psProd.executeQuery();

    if (rsProd.next() && rsProd.getInt("stock") >= quantidade) {
        double preco_unit = rsProd.getDouble("preco");
        double total = preco_unit * quantidade;

        PreparedStatement psSaldo = conn.prepareStatement("SELECT saldo FROM carteira WHERE id_utilizador = ?");
        psSaldo.setInt(1, id_utilizador);
        ResultSet rsSaldo = psSaldo.executeQuery();
        double saldo = rsSaldo.next() ? rsSaldo.getDouble("saldo") : 0;

        if (saldo >= total) {
            PreparedStatement psDesconta = conn.prepareStatement("UPDATE carteira SET saldo = saldo - ? WHERE id_utilizador = ?");
            psDesconta.setDouble(1, total);
            psDesconta.setInt(2, id_utilizador);
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
            psEnc.setInt(2, id_utilizador);
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
            psLinha.setDouble(4, preco_unit);
            psLinha.executeUpdate();

            PreparedStatement psMov = conn.prepareStatement(
                "INSERT INTO movimentos_carteira (id_utilizador_op, operacao, valor, carteira_origem, carteira_destino, id_encomenda) VALUES (?, 'pagamento_encomenda', ?, ?, 100, ?)"
            );
            psMov.setInt(1, id_utilizador);
            psMov.setDouble(2, total);
            psMov.setInt(3, id_utilizador);
            psMov.setInt(4, id_encomenda);
            psMov.executeUpdate();

            PreparedStatement psStock = conn.prepareStatement("UPDATE produto SET stock = stock - ? WHERE id_produto = ?");
            psStock.setInt(1, quantidade);
            psStock.setInt(2, id_produto);
            psStock.executeUpdate();

            mensagem = "Encomenda criada! Código: " + codigo;
        } else {
            mensagem = "Saldo insuficiente!";
            isErro = true;
        }
    } else {
        mensagem = "Stock insuficiente!";
        isErro = true;
    }
}

String ordem = request.getParameter("ordem");
String orderBy = "id_produto";
if ("nome_asc".equals(ordem))   orderBy = "nome ASC";
if ("nome_desc".equals(ordem))  orderBy = "nome DESC";
if ("preco_asc".equals(ordem))  orderBy = "preco ASC";
if ("preco_desc".equals(ordem)) orderBy = "preco DESC";
if ("stock_asc".equals(ordem))  orderBy = "stock ASC";
if ("stock_desc".equals(ordem)) orderBy = "stock DESC";

PreparedStatement psList = conn.prepareStatement(
    "SELECT id_produto, nome, descricao, preco, stock, categoria FROM produto WHERE ativo = 1 ORDER BY " + orderBy
);
ResultSet rsList = psList.executeQuery();

List<Map<String, Object>> produtos = new ArrayList<>();
while (rsList.next()) {
    Map<String, Object> p = new HashMap<>();
    p.put("id_produto", rsList.getInt("id_produto"));
    p.put("nome", rsList.getString("nome"));
    p.put("descricao", rsList.getString("descricao"));
    p.put("preco", rsList.getDouble("preco"));
    p.put("stock", rsList.getInt("stock"));
    p.put("categoria", rsList.getString("categoria"));
    produtos.add(p);
}
rsList.close();
psList.close();

String classeMensagem = isErro ? "erro" : "mensagem";
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
      max-width: 1000px;
      background: white;
      padding: 30px;
      border-radius: 10px;
      box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
    }

    h2 { text-align: center; color: #333; }

    .mensagem { padding: 10px; background: #e8f5e9; border-left: 4px solid #4CAF50; margin-bottom: 15px; border-radius: 4px; }
    .erro     { padding: 10px; background: #ffe8e8; border-left: 4px solid #f44336; margin-bottom: 15px; border-radius: 4px; }

    .ordenar { margin: 15px 0; text-align: right; }
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
  <div class="nav-left">FelixUberShop</div>
  <div class="nav-right">
    <a href="PagIniCliente.jsp">Voltar</a>
    <a href="Logout.jsp">Log Out</a>
  </div>
</div>

<div class="container">
  <h2>Produtos Disponíveis</h2>

  <div class="<%= classeMensagem %>" <%= mensagem.isEmpty() ? "style='display:none'" : "" %>><%= mensagem %></div>

  <form method="get" class="ordenar">
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
      <th>Nome</th>
      <th>Categoria</th>
      <th>Descrição</th>
      <th>Preço</th>
      <th>Stock</th>
      <th>Quantidade</th>
      <th>Comprar</th>
    </tr>
    <% for (Map<String, Object> p : produtos) { %>
      <tr>
        <form method="post">
          <td><%= p.get("nome") %></td>
          <td><%= p.get("categoria") %></td>
          <td><%= p.get("descricao") %></td>
          <td><%= p.get("preco") %> €</td>
          <td><%= p.get("stock") %></td>
          <td><input type="number" name="quantidade" value="1" min="1" max="<%= p.get("stock") %>"></td>
          <td>
            <input type="hidden" name="id_produto" value="<%= p.get("id_produto") %>">
            <button type="submit" name="comprar" class="comprar-btn">Comprar</button>
          </td>
        </form>
      </tr>
    <% } %>
  </table>
</div>

</body>
</html>