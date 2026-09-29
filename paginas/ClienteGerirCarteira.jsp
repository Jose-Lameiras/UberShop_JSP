<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("2")) {
    response.sendRedirect("Logout.jsp");
}

int id_utilizador = (Integer) session.getAttribute("id_utilizador");
double saldo = 0;

// saldo atual
PreparedStatement psAtual = conn.prepareStatement("SELECT saldo FROM carteira WHERE id_utilizador = ?");
psAtual.setInt(1, id_utilizador);
ResultSet res = psAtual.executeQuery();
if (res.next()) {
    saldo = res.getDouble("saldo");
}

// Adicionar saldo
if ("POST".equals(request.getMethod()) && request.getParameter("adicionar") != null) {
    double valor = Double.parseDouble(request.getParameter("valor"));
    if (valor > 0) {
        PreparedStatement psAdicionar = conn.prepareStatement("UPDATE carteira SET saldo = saldo + ? WHERE id_utilizador = ?");
        psAdicionar.setDouble(1, valor);
        psAdicionar.setInt(2, id_utilizador);
        psAdicionar.executeUpdate();

        PreparedStatement psMov = conn.prepareStatement(
            "INSERT INTO movimentos_carteira (id_utilizador_op, operacao, valor, carteira_destino) VALUES (?, 'adicionar', ?, ?)"
        );
        psMov.setInt(1, id_utilizador);
        psMov.setDouble(2, valor);
        psMov.setInt(3, id_utilizador);
        psMov.executeUpdate();

        response.sendRedirect("ClienteGerirCarteira.jsp");
    }
}

// Levantar saldo
if ("POST".equals(request.getMethod()) && request.getParameter("levantar") != null) {
    double valor = Double.parseDouble(request.getParameter("valor"));
    if (valor > 0 && valor <= saldo) {
        PreparedStatement psLevantar = conn.prepareStatement("UPDATE carteira SET saldo = saldo - ? WHERE id_utilizador = ?");
        psLevantar.setDouble(1, valor);
        psLevantar.setInt(2, id_utilizador);
        psLevantar.executeUpdate();

        PreparedStatement psMov = conn.prepareStatement(
            "INSERT INTO movimentos_carteira (id_utilizador_op, operacao, valor, carteira_origem) VALUES (?, 'levantar', ?, ?)"
        );
        psMov.setInt(1, id_utilizador);
        psMov.setDouble(2, valor);
        psMov.setInt(3, id_utilizador);
        psMov.executeUpdate();

        response.sendRedirect("ClienteGerirCarteira.jsp");
    }
}
%>

<!DOCTYPE html>
<html lang="pt">

<head>
    <meta charset="UTF-8">
    <title>Carteira</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

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

        .navbar a {
            color: white;
            text-decoration: none;
            margin-left: 20px;
            font-weight: bold;
        }

        .navbar a:hover {
            text-decoration: underline;
        }

        h1 {
            color: #333;
            margin-bottom: 40px;
            text-align: center;
        }

        .carteira-container {
            background: #fff;
            padding: 30px 40px;
            border-radius: 12px;
            box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
            margin-top: 20px;
            min-width: 320px;
        }

        .carteira-container h2 {
            margin-bottom: 20px;
        }

        .carteira-container p {
            margin-bottom: 25px;
            font-size: 18px;
        }

        form {
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-bottom: 18px;
        }

        label {
            font-weight: bold;
        }

        input[type="number"] {
            padding: 8px;
            border-radius: 6px;
            border: 1px solid #ccc;
            font-size: 16px;
        }

        button {
            padding: 10px;
            border: none;
            border-radius: 6px;
            background-color: hsl(122, 39.40%, 49.20%);
            color: white;
            font-size: 16px;
            cursor: pointer;
            transition: background 0.2s;
        }

        button:hover {
            background-color: #0056b3;
        }
    </style>
</head>

<body>
    <div class="navbar">
        <div class="nav-left">Carteira</div>
        <div class="nav-right">
            <a href="PagIniCliente.jsp">Voltar</a>
            <a href="Logout.jsp">Log Out</a>
        </div>
    </div>

    <h1>Carteira</h1>
    <div class="carteira-container">
        <h2>Minha Carteira</h2>
        <p><strong>Saldo atual:</strong> <%= String.format("%.2f", saldo) %> €</p>

        <form method="post">
            <label>Valor a adicionar:</label>
            <input type="number" name="valor" min="1" step="0.01" required>
            <button type="submit" name="adicionar">Adicionar saldo</button>
        </form>

        <form method="post">
            <label>Valor a levantar:</label>
            <input type="number" name="valor" min="1" max="<%= saldo %>" step="0.01" required>
            <button type="submit" name="levantar">Levantar saldo</button>
        </form>
    </div>
</body>

</html>
