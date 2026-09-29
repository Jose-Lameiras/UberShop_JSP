<%--
    basedados.h
    Módulo único de ligação à base de dados MySQL "felixubershop".
    Todas as páginas da aplicação devem incluir este ficheiro com:
        <%@ include file="../basedados/basedados.h" %>
    Nenhuma outra parte do código pode abrir ligações ao MySQL.
--%>
<%@ page import="java.sql.*" %>
<%
    // Variável de ligação partilhada por todas as páginas que incluem este módulo
    Connection conn = null;

    try {
        // Carregar o driver JDBC do MySQL (com.mysql.jdbc.Driver para versões mais antigas
        // ou com.mysql.cj.jdbc.Driver para Connector/J 8+).
        Class.forName("com.mysql.jdbc.Driver").newInstance();

        // String de ligação à BD do projeto. XAMPP por defeito: porta 3306, user "root" sem password.
        String jdbcURL = "jdbc:mysql://localhost:3306/felixubershop?useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC";
        conn = DriverManager.getConnection(jdbcURL, "root", "");
    } catch (Exception e) {
        // Em caso de falha, mostra mensagem de diagnóstico (apenas para desenvolvimento).
        out.println("Erro ao conectar ao MySQL: " + e.getMessage());
    }
%>