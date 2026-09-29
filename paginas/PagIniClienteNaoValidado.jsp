<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("4")) {
    response.sendRedirect("login.jsp");
}
%>

<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Conta em Verificação</title>
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
      margin-top: 60px;
      width: 100%;
      max-width: 450px;
      background: white;
      padding: 40px;
      border-radius: 10px;
      box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
      text-align: center;
    }

    h2 {
      color: #2e7d32;
      margin-bottom: 15px;
    }

    p {
      color: #555;
      margin-bottom: 25px;
      font-size: 15px;
    }

    button[type="submit"] {
      padding: 12px 24px;
      background-color: hsl(122, 39.40%, 49.20%);
      color: white;
      border: none;
      border-radius: 6px;
      font-size: 16px;
      cursor: pointer;
    }

    button[type="submit"]:hover {
      background-color: #388E3C;
    }
  </style>
</head>
<body>

  <div class="navbar">
    <div class="nav-left">FelixUberShop</div>
    <div class="nav-right">
      <a href="index.jsp">Início</a>
      <a href="Logout.jsp">Log Out</a>
    </div>
  </div>

  <div class="container">
    <h2>Conta em verificação!</h2>
    <p>A tua conta ainda está a ser verificada. Aguarda a aprovação de um administrador para poderes fazer compras.</p>
    <form action="index.jsp" method="get">
      <button type="submit">Voltar para o Início</button>
    </form>
  </div>

</body>
</html>