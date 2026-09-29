<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*, java.security.MessageDigest" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("1")) {
    response.sendRedirect("Logout.jsp");
    return;
}

if (request.getParameter("mail") == null) {
    response.sendRedirect("AdminGerirUtilizadores.jsp");
    return;
}

String mail = request.getParameter("mail");
String erro = "";

PreparedStatement psUser = conn.prepareStatement("SELECT * FROM utilizador WHERE mail = ?");
psUser.setString(1, mail);
ResultSet rsUser = psUser.executeQuery();

if (!rsUser.next()) {
    response.sendRedirect("AdminGerirUtilizadores.jsp");
    return;
}

String nomeUtilizador = rsUser.getString("nomeUtilizador");
String mailUtilizador = rsUser.getString("mail");
String pass           = rsUser.getString("pass");
String telemovel      = rsUser.getString("telemovel");
String tipoUtilizador = rsUser.getString("tipoUtilizador");
rsUser.close();
psUser.close();

PreparedStatement psTipos = conn.prepareStatement("SELECT id_Tipo, descricao FROM tipoutilizador");
ResultSet rsTipos = psTipos.executeQuery();
List<Map<String, String>> tipos = new ArrayList<>();
while (rsTipos.next()) {
    Map<String, String> row = new LinkedHashMap<>();
    row.put("id", String.valueOf(rsTipos.getInt("id_Tipo")));
    row.put("descricao", rsTipos.getString("descricao"));
    tipos.add(row);
}
rsTipos.close();
psTipos.close();

if ("POST".equals(request.getMethod())) {
    String novoNome      = request.getParameter("nomeUtilizador");
    String novoMail      = request.getParameter("mail");
    String novaPass      = request.getParameter("pass");
    String novoTelemovel = request.getParameter("telemovel");
    String novoTipo      = request.getParameter("tipoUtilizador");

    String passFinal = pass;
    if (novaPass != null && !novaPass.trim().isEmpty()) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            md.update(novaPass.getBytes());
            byte[] digest = md.digest();
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) sb.append(String.format("%02x", b & 0xff));
            passFinal = sb.toString();
        } catch (Exception e) { /* mantém pass original */ }
    }

    try {
        PreparedStatement psUpdate = conn.prepareStatement(
            "UPDATE utilizador SET nomeUtilizador = ?, mail = ?, pass = ?, telemovel = ?, tipoUtilizador = ? WHERE mail = ?"
        );
        psUpdate.setString(1, novoNome);
        psUpdate.setString(2, novoMail);
        psUpdate.setString(3, passFinal);
        psUpdate.setString(4, novoTelemovel);
        psUpdate.setString(5, novoTipo);
        psUpdate.setString(6, mail);
        psUpdate.executeUpdate();
        psUpdate.close();
        response.sendRedirect("AdminGerirUtilizadores.jsp");
        return;
    } catch (java.sql.SQLException e) {
        if (e.getMessage().contains("telemovel")) {
            erro = "Já existe outro utilizador com esse telemóvel.";
        } else if (e.getMessage().contains("mail")) {
            erro = "Já existe outro utilizador com esse email.";
        } else {
            erro = "Erro ao atualizar: " + e.getMessage();
        }
    }
}
%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Editar Utilizador - Admin</title>
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
      max-width: 500px;
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

    .erro {
      background: #ffe8e8;
      border-left: 4px solid #f44336;
      padding: 10px;
      margin-bottom: 15px;
      border-radius: 4px;
      color: #b71c1c;
    }

    label { margin-top: 15px; display: block; font-weight: bold; }

    input, select {
      width: 100%;
      padding: 8px;
      margin-top: 5px;
      border-radius: 4px;
      border: 1px solid #ccc;
    }
    input:focus, select:focus {
      outline: none;
      border-color: hsl(122, 39.40%, 49.20%);
      box-shadow: 0 0 0 2px rgba(76, 175, 80, 0.2);
    }

    .btn { margin-top: 20px; padding: 10px 20px; border: none; cursor: pointer; border-radius: 4px; }
    .save-btn { background-color: hsl(122, 39.40%, 49.20%); color: white; }
    .save-btn:hover { background-color: #388E3C; }
    .back-btn {
      background-color: #888;
      color: white;
      margin-left: 10px;
      text-decoration: none;
      display: inline-block;
    }
    .back-btn:hover { background-color: #555; }
  </style>
</head>
<body>

<div class="navbar">
  <div class="nav-left">FelixUberShop - Admin</div>
  <div class="nav-right">
    <a href="AdminGerirUtilizadores.jsp">Voltar</a>
    <a href="Logout.jsp">Log Out</a>
  </div>
</div>

<div class="container">
  <h2>A editar: <%= nomeUtilizador %></h2>

  <% if (!erro.isEmpty()) { %>
  <div class="erro"><%= erro %></div>
  <% } %>

  <form method="POST">
    <label>Nome de Utilizador</label>
    <input type="text" name="nomeUtilizador" value="<%= nomeUtilizador %>" required>

    <label>Email</label>
    <input type="email" name="mail" value="<%= mailUtilizador %>" required>

    <label>Nova Password (deixar em branco para manter a atual)</label>
    <input type="password" name="pass" placeholder="Deixe em branco para não alterar">

    <label>Telemóvel</label>
    <input type="text" name="telemovel" value="<%= telemovel %>">

    <label>Tipo de Utilizador</label>
    <select name="tipoUtilizador" required>
      <% for (Map<String, String> tipo : tipos) { %>
      <option value="<%= tipo.get("id") %>" <%= tipoUtilizador.equals(tipo.get("id")) ? "selected" : "" %>>
        <%= tipo.get("descricao") %>
      </option>
      <% } %>
    </select>

    <button class="btn save-btn" type="submit">Guardar Alterações</button>
    <a href="AdminGerirUtilizadores.jsp" class="btn back-btn">Cancelar</a>
  </form>
</div>

</body>
</html>
