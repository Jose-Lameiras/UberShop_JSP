# UberShop (JSP)

Loja online desenvolvida em **Java (JSP/Servlets) com JDBC e MySQL**, no âmbito da licenciatura em Engenharia Informática (IPCB).

## Funcionalidades

- Registo e login de utilizadores, com validação de novos clientes.
- **Três perfis**: cliente, funcionário e administrador, cada um com a sua área.
- Catálogo de produtos com gestão de **stock** e **promoções**.
- **Encomendas**: o cliente encomenda, funcionários e administrador gerem o estado.
- **Carteira digital** do cliente e gestão de saldos.
- Gestão de utilizadores e perfis pelo administrador.

## Tecnologias

- Java, JSP, Servlets
- JDBC com `PreparedStatement`
- MySQL (scripts em `basedados/`)
- HTML/CSS

## Estrutura

| Pasta | Conteúdo |
| --- | --- |
| `paginas/` | Páginas JSP (cliente, funcionário, administrador) |
| `basedados/` | Scripts para criar e apagar a base de dados |
| `relatorio/` | Relatório do projeto |
