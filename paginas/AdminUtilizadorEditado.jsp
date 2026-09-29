<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("1")) {
    response.sendRedirect("Logout.jsp");
}
%>

<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Utilizador Editado</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f4f4f4;
      display: flex; flex-direction: column;
      align-items: center; justify-content: center;
      height: 100vh; margin: 0;
    }
    .message-box {
      background-color: #ffffff;
      padding: 30px;
      border-radius: 8px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.2);
      text-align: center;
    }
    h1 { color: hsl(122, 39%, 35%); }
    .btn {
      margin-top: 20px; padding: 10px 20px;
      background-color: hsl(122, 39.40%, 49.20%); color: white;
      text-decoration: none; border-radius: 5px;
      display: inline-block;
    }
    .btn:hover { background-color: #43a047; }
  </style>
</head>
<body>

<div class="message-box">
  <h1>Utilizador editado com sucesso!</h1>
  <a href="AdminGerirUtilizadores.jsp" class="btn">Voltar à gestão</a>
</div>

</body>
</html>
