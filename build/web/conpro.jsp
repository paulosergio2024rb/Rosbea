<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.ResultSet"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Lista de Produtos</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            background-color: #f9f9f9;
            color: #333;
            padding: 40px 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        h1 {
            color: #1976d2;
            margin-bottom: 30px;
            font-size: 1.8rem;
        }

        table {
            border-collapse: collapse;
            width: 100%;
            max-width: 800px;
            background-color: #fff;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            border-radius: 8px;
            overflow: hidden;
        }

        th, td {
            padding: 15px 20px;
            text-align: left;
        }

        th {
            background-color: #1976d2;
            color: #fff;
        }

        tr:nth-child(even) {
            background-color: #f5f5f5;
        }

        tr:hover {
            background-color: #e0f7fa;
        }

        .error-message {
            color: red;
            margin-top: 20px;
        }

        @media (max-width: 600px) {
            table, th, td {
                font-size: 0.9rem;
                padding: 10px;
            }
        }
    </style>
</head>
<body>
    <h1>Resultado da Consulta</h1>
    <%
        String n = request.getParameter("nome");

        try {
            Connection conecta;
            PreparedStatement st;
            Class.forName("org.mariadb.jdbc.Driver");
            conecta = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
            st = conecta.prepareStatement("SELECT * FROM produto WHERE nome LIKE ? ORDER BY nome");
            st.setString(1, "%" + n + "%");
            ResultSet rs = st.executeQuery();

            if (!rs.isBeforeFirst()) {
    %>
                <p class="error-message">Nenhum produto encontrado com o nome "<strong><%= n %></strong>".</p>
    <%
            } else {
    %>
                <table>
                    <tr>
                        <th>Código</th>
                        <th>Nome</th>
                        <th>inspirado</th>
                        <th>Preço</th>
                    </tr>
                    <%
                        while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getString("codigo") %></td>
                        <td><%= rs.getString("nome") %></td>
                        <td><%= rs.getString("inspirado") %></td>
                        <td>R$ <%= rs.getString("preco") %></td>
                    </tr>
                    <%
                        }
                    %>
                </table>
    <%
            }
            rs.close();
            st.close();
            conecta.close();
        } catch (Exception x) {
    %>
        <p class="error-message">Erro ao consultar produtos: <%= x.getMessage() %></p>
    <%
        }
    %>
</body>
</html>
