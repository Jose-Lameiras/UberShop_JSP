<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("3")) {
    response.sendRedirect("Logout.jsp");
    return;
}

int id_utilizador = (Integer) session.getAttribute("id_utilizador");
String erro = "";

if ("POST".equals(request.getMethod())) {
    String nome = request.getParameter("nomeUtilizador");
    String mail = request.getParameter("mail");
    String telemovel = request.getParameter("telemovel");
    String pass = request.getParameter("pass");

    try {
        if (pass != null && !pass.trim().isEmpty()) {
            MessageDigest md = MessageDigest.getInstance("MD5");
            md.update(pass.getBytes());
            byte[] digest = md.digest();
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) sb.append(String.format("%02x", b & 0xff));
            String pass_encriptada = sb.toString();

            PreparedStatement ps = conn.prepareStatement(
                "UPDATE utilizador SET nomeUtilizador=?, mail=?, telemovel=?, pass=? WHERE id_utilizador=?"
            );
            ps.setString(1, nome);
            ps.setString(2, mail);
            ps.setString(3, telemovel);
            ps.setString(4, pass_encriptada);
            ps.setInt(5, id_utilizador);
            ps.executeUpdate();
        } else {
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE utilizador SET nomeUtilizador=?, mail=?, telemovel=? WHERE id_utilizador=?"
            );
            ps.setString(1, nome);
            ps.setString(2, mail);
            ps.setString(3, telemovel);
            ps.setInt(4, id_utilizador);
            ps.executeUpdate();
        }
        response.sendRedirect("FuncGerirPerfil.jsp");
        return;
    } catch (SQLException e) {
        if (e.getMessage().contains("telemovel")) {
            erro = "Já existe um utilizador com esse telemóvel.";
        } else if (e.getMessage().contains("mail")) {
            erro = "Já existe um utilizador com esse email.";
        } else {
            erro = "Erro ao atualizar dados: " + e.getMessage();
        }
    }
}

PreparedStatement psProcurar = conn.prepareStatement(
    "SELECT nomeUtilizador, mail, telemovel FROM utilizador WHERE id_utilizador = ?"
);
psProcurar.setInt(1, id_utilizador);
ResultSet res = psProcurar.executeQuery();
res.next();

String nomeAtual = res.getString("nomeUtilizador");
String mailAtual = res.getString("mail");
String telemovelAtual = res.getString("telemovel");
String classeErro = erro.isEmpty() ? "style=\'display:none\'" : "";
%>
<!DOCTYPE html>
<html lang="pt">

<head>
  <meta charset="UTF-8">
  <title>Editar Perfil</title>
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

    .perfil-container {
      background: #fff; padding: 32px 48px; border-radius: 14px;
      box-shadow: 0 4px 18px rgba(0,0,0,0.10); margin-top: 30px;
      min-width: 340px; max-width: 400px;
    }
    .perfil-container h2 { color: #2e7d32; margin-bottom: 24px; text-align: center; }

    .perfil-form { display: flex; flex-direction: column; gap: 16px; }
    .perfil-form label { font-weight: bold; }
    .perfil-form input { padding: 8px; border-radius: 6px; border: 1px solid #ccc; font-size: 16px; }

    .erro {
      background: #ffe8e8; color: #b71c1c; padding: 10px; border-radius: 6px;
      margin-bottom: 15px; border-left: 4px solid #f44336;
    }

    .btn {
      padding: 12px 32px; background: hsl(122, 39.40%, 49.20%); color: #fff;
      border: none; border-radius: 8px; font-size: 16px; cursor: pointer;
    }
    .btn:hover { background: #0056b3; }
  </style>
</head>

<body>

<div class="navbar">
  <div class="nav-left">Editar Perfil</div>
  <div class="nav-right">
    <a href="PagIniFuncionario.jsp">Voltar</a>
    <a href="Logout.jsp">Log Out</a>
  </div>
</div>

<div class="perfil-container">
  <h2>Alterar Dados</h2>

  <div class="erro" <%= erro.isEmpty() ? "style='display:none'" : "" %>><%= erro %></div>

  <form class="perfil-form" method="post">
    <label>Nome:</label>
    <input type="text" name="nomeUtilizador" value="<%= nomeAtual %>" required>
    <label>Email:</label>
    <input type="email" name="mail" value="<%= mailAtual %>" required>
    <label>Telemóvel:</label>
    <input type="text" name="telemovel" value="<%= telemovelAtual %>" required>
    <label>Nova Password (opcional):</label>
    <input type="password" name="pass" placeholder="Deixe em branco para não alterar">
    <button class="btn" type="submit">Guardar Alterações</button>
    <a href="FuncGerirPerfil.jsp"><button class="btn" type="button">Voltar para o Perfil</button></a>
  </form>
</div>

</body>
</html>
