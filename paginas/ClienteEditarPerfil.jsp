<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%@ include file="../basedados/basedados.h" %>
<%
if (session.getAttribute("tipoUtilizador") == null || !session.getAttribute("tipoUtilizador").equals("2")) {
    response.sendRedirect("Logout.jsp");
}

int id_utilizador = (Integer) session.getAttribute("id_utilizador");

// Atualizar dados
if ("POST".equals(request.getMethod())) {
    String nomeNovo = request.getParameter("nomeUtilizador");
    String emailNovo = request.getParameter("mail");
    String telemovelNovo = request.getParameter("telemovel");
    String passwordNova = request.getParameter("pass");

    try {
        if (passwordNova != null && !passwordNova.trim().isEmpty()) {
            String passwordHash = "";
            try {
                MessageDigest md = MessageDigest.getInstance("MD5");
                md.update(passwordNova.getBytes());
                byte[] digest = md.digest();
                StringBuilder sb = new StringBuilder();
                for (byte b : digest) {
                    sb.append(String.format("%02x", b & 0xff));
                }
                passwordHash = sb.toString();
            } catch (Exception e) {
                out.println("Erro ao encriptar password: " + e.getMessage());
            }

            String sqlAtualizar = "UPDATE utilizador SET nomeUtilizador = ?, mail = ?, telemovel = ?, pass = ? WHERE id_utilizador = ?";
            PreparedStatement ps = conn.prepareStatement(sqlAtualizar);
            ps.setString(1, nomeNovo);
            ps.setString(2, emailNovo);
            ps.setString(3, telemovelNovo);
            ps.setString(4, passwordHash);
            ps.setInt(5, id_utilizador);
            ps.executeUpdate();
        } else {
            String sqlAtualizar = "UPDATE utilizador SET nomeUtilizador = ?, mail = ?, telemovel = ? WHERE id_utilizador = ?";
            PreparedStatement ps = conn.prepareStatement(sqlAtualizar);
            ps.setString(1, nomeNovo);
            ps.setString(2, emailNovo);
            ps.setString(3, telemovelNovo);
            ps.setInt(4, id_utilizador);
            ps.executeUpdate();
        }

        response.sendRedirect("ClienteGerirPerfil.jsp");
    } catch (SQLException e) {
        out.println("Erro ao atualizar perfil: " + e.getMessage());
    }
}


String nomeUtilizador = "";
String emailUtilizador = "";
String telemovelUtilizador = "";

try {
    String sqlBuscar = "SELECT nomeUtilizador, mail, telemovel FROM utilizador WHERE id_utilizador = ?";
    PreparedStatement psBuscar = conn.prepareStatement(sqlBuscar);
    psBuscar.setInt(1, id_utilizador);
    ResultSet resultadoBusca = psBuscar.executeQuery();
    if (resultadoBusca.next()) {
        nomeUtilizador = resultadoBusca.getString("nomeUtilizador");
        emailUtilizador = resultadoBusca.getString("mail");
        telemovelUtilizador = resultadoBusca.getString("telemovel");
    }
} catch (SQLException e) {
    out.println("Erro ao buscar dados do utilizador: " + e.getMessage());
}
%>

<!DOCTYPE html>
<html lang="pt">

<head>
    <meta charset="UTF-8">
    <title>Editar Perfil</title>
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

        .perfil-container {
            background: #fff;
            padding: 32px 48px;
            border-radius: 14px;
            box-shadow: 0 4px 18px rgba(0, 0, 0, 0.10);
            margin-top: 30px;
            min-width: 340px;
            max-width: 400px;
        }

        .perfil-container h2 {
            color: #2e7d32;
            margin-bottom: 24px;
            text-align: center;
        }

        .perfil-form {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .perfil-form label {
            font-weight: bold;
        }

        .perfil-form input {
            padding: 8px;
            border-radius: 6px;
            border: 1px solid #ccc;
            font-size: 16px;
        }

        .editar-btn {
            padding: 12px 32px;
            background: hsl(122, 39.40%, 49.20%);
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
            transition: background 0.2s;
        }

        .editar-btn:hover {
            background: #0056b3;
        }
    </style>
</head>

<body>
    <div class="navbar">
        <div class="nav-left">Editar Perfil</div>
        <div class="nav-right">
            <a href="PagIniCliente.jsp">Voltar</a>
            <a href="Logout.jsp">Log Out</a>
        </div>
    </div>

    <h1>Editar Perfil</h1>

    <div class="perfil-container">
        <h2>Alterar Dados</h2>
        <form class="perfil-form" method="post">
            <label>Nome:</label>
            <input type="text" name="nomeUtilizador" value="<%= nomeUtilizador %>" required>
            <label>Email:</label>
            <input type="email" name="mail" value="<%= emailUtilizador %>" required>
            <label>Telemóvel:</label>
            <input type="text" name="telemovel" value="<%= telemovelUtilizador %>" required>
            <label>Nova Password (opcional):</label>
            <input type="password" name="pass" placeholder="Deixe em branco para não alterar">
            <button class="editar-btn" type="submit">Guardar Alterações</button>
            <button type="button" class="editar-btn" onclick="window.location.href='ClienteGerirPerfil.jsp'">
                Voltar para o Perfil
            </button>
        </form>
    </div>
</body>

</html>
