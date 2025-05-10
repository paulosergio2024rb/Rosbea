<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Lista de Produtos</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            font-size: 10pt;
            margin: 10px;
            background-color: #f9f9f9;
        }

        h1 {
            font-size: 16pt;
            margin-bottom: 15px;
            color: #333;
        }

        form {
            background-color: #fff;
            border: 1px solid #ddd;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }

        label {
            font-size: 12pt;
            font-weight: bold;
            display: block;
            margin-bottom: 5px;
            color: #555;
        }

        input[type="number"] {
            font-size: 12pt;
            padding: 8px;
            width: 150px;
            margin-bottom: 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            outline: none;
        }

        input[type="number"]:focus {
            border-color: #66afe9;
            box-shadow: 0 0 8px rgba(102, 175, 233, 0.6);
        }

        button {
            font-size: 10pt;
            padding: 5px 10px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-right: 10px; /* Adiciona espaço entre os botões */
        }

        button:hover {
            background-color: #45a049;
        }

        /* Flexbox para organizar os botões lado a lado */
        .form-buttons {
            display: flex;
            justify-content: flex-start; /* Alinha à esquerda */
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        td {
            vertical-align: top;
            width: 50%;
            padding: 0 5px;
        }

        .produto-item {
            margin-bottom: 3px;
        }

        @media print {
            @page {
                size: A5;
                margin: 10mm;
            }

            form, button {
                display: none;
            }

            body {
                margin: 0;
            }
        }
    </style>
</head>
<body>

<h1>Filtrar Produtos por Nível</h1>

<form method="get">
    <label for="nivelFiltro">Digite o Nível para Filtrar:</label>
    <input type="number" id="nivelFiltro" name="nivelFiltro"
           value="<%= request.getParameter("nivelFiltro") != null ? request.getParameter("nivelFiltro") : "" %>">

    <div class="form-buttons">
        <button type="submit">Filtrar</button>
        <button type="button" onclick="window.print()">Imprimir</button>
    </div>
</form>

<%
    String dbURL = "jdbc:mariadb://localhost:3306/Rosbea";
    String dbUser = "paulo";
    String dbPassword = "6421";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String nivelFiltroStr = request.getParameter("nivelFiltro");
    int nivelFiltro = -1;
    boolean filtroAplicado = false;

    java.util.List<String> produtos = new java.util.ArrayList<>();

    if (nivelFiltroStr != null && !nivelFiltroStr.isEmpty()) {
        try {
            nivelFiltro = Integer.parseInt(nivelFiltroStr);
            filtroAplicado = true;
        } catch (NumberFormatException e) {
            out.println("<p style='color:red;'>Digite um número válido.</p>");
        }
    }

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

        String sql = "SELECT nome_produto FROM vw_controle_estoque";
        if (filtroAplicado) {
            sql += " WHERE lista_preco = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, nivelFiltro);
        } else {
            pstmt = conn.prepareStatement(sql);
        }

        rs = pstmt.executeQuery();

        while (rs.next()) {
            produtos.add(rs.getString("nome_produto"));
        }

    } catch (Exception e) {
        out.println("<p>Erro ao acessar o banco de dados: " + e.getMessage() + "</p>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ignored) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
        try { if (conn != null) conn.close(); } catch (Exception ignored) {}
    }
%>

<table>
    <tr>
        <td>
            <%
                for (int i = 0; i < produtos.size(); i += 2) {
                    out.println("<div class='produto-item'>" + produtos.get(i) + "</div>");
                }
            %>
        </td>
        <td>
            <%
                for (int i = 1; i < produtos.size(); i += 2) {
                    out.println("<div class='produto-item'>" + produtos.get(i) + "</div>");
                }
            %>
        </td>
    </tr>
</table>

</body>
</html>
