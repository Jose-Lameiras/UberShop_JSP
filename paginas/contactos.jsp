<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>


<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Contactos Felix Bus</title>
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

    /* NAVBAR */
    .navbar {
      position: fixed;
      top: 0;
      width: 100%;
      background-color:hsl(122, 39.40%, 49.20%);
      color: white;
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 15px 30px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.2);
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

    .nav-left {
      font-size: 18px;
      font-weight: bold;
    }
    .conteudo {
  padding-top: 80px;    
    }

    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th, td { border: 1px solid #ccc; padding: 10px; text-align: center; }
    th { background-color: hsl(122, 39.40%, 49.20%); color: white; }


    tr:nth-child(even) {
  background-color: #dddddd;
    }

    /* Estilo para o mapa */
    .mapa-container {
      margin-top: 30px;
      text-align: center;
    }

    .mapa-container h2 {
      margin-bottom: 20px;
      color: #333;
    }

    .mapa {
      display: flex;
      justify-content: center;
      margin-top: 20px;
    }

    .mapa iframe {
      border-radius: 8px;
      box-shadow: 0 4px 8px rgba(0,0,0,0.2);
    }

  </style>
</head>
<body>

<!-- NAVBAR -->
<div class="navbar">
  <div class="nav-left">Contactos</div>
  <div class="nav-right">
    <a href="login.jsp">Login</a>
    <a href="registo.jsp">Registar</a>
    <a href="index.jsp">Voltar</a>
  </div>
</div>

<div class="conteudo">
    <table>
        <tr><br><h1>Horario de atendimento <h1></br></tr>
        <th>Segunda</th>
        <th>Terça</th>
        <th>Quarta</th>
        <th>Quinta</th>
        <th>Sexta</th>
        <th>Sabado</th>
        <tr>
            <td>8:30-20:00</td>
            <td>8:30-20:00</td>
            <td>8:30-20:00</td>
            <td>8:30-20:00</td>
            <td>8:30-20:00</td>
            <td>10:30-13:30</td>

        </tr>
    </table> 

    <div class="mapa-container">
        <h3>Para mais informações contacte mercearia@felixubershop.com</h3>
        <h2>Localização</h2>

        <div class="mapa">
            <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3575.1821117162567!2d-7.512379300000002!3d39.819511000000006!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0xd3d5ea6bb2280e1%3A0x1c460157bc4b46c8!2sEscola%20Superior%20de%20Tecnologia%20-%20Instituto%20Polit%C3%A9cnico%20de%20Castelo%20Branco!5e1!3m2!1spt-PT!2spt!4v1746890141540!5m2!1spt-PT!2spt"
                width="600"
                height="400"
                style="border:0;"
                allowfullscreen=""
                loading="lazy"
                referrerpolicy="no-referrer-when-downgrade">
            </iframe>
        </div>
    </div>
</div>

</body>
</html>
