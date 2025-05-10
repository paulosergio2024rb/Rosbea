<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Movimentações do Caixa</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #4361ee;
            --success-color: #4cc9f0;
            --danger-color: #f72585;
            --light-color: #f8f9fa;
            --dark-color: #212529;
            --border-radius: 6px;
            --box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        body {
            font-family: 'Roboto', sans-serif;
            margin: 20px;
            padding: 0;
            background-color: #f5f7fa;
            color: #333;
            line-height: 1.6;
        }
        
        h1 {
            color: var(--dark-color);
            text-align: center;
            margin-bottom: 25px;
            font-weight: 500;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
        
        .positivo {
            color: green;
            font-weight: bold;
        }
        
        .negativo {
            color: red;
            font-weight: bold;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            box-shadow: var(--box-shadow);
            table-layout: fixed;
        }
        
        th {
            color: white;
            padding: 12px;
            text-align: center;
        }
        
        .data-header {
            background-color: var(--primary-color);
            width: 15%;
        }
        
        .entrada-header {
            background-color: var(--success-color);
            width: 35%;
        }
        
        .saida-header {
            background-color: var(--danger-color);
            width: 35%;
        }
        
        .acoes-header {
            background-color: var(--dark-color);
            width: 15%;
        }
        
        td {
            padding: 10px 12px;
            border-bottom: 1px solid #eee;
            text-align: center;
            word-wrap: break-word;
        }
        
        .data-cell {
            text-align: left;
            font-weight: 500;
            width: 15%;
        }
        
        .entrada-cell {
            background-color: rgba(76, 201, 240, 0.1);
            width: 35%;
        }
        
        .saida-cell {
            background-color: rgba(247, 37, 133, 0.1);
            width: 35%;
        }
        
        .acoes-cell {
            width: 15%;
        }
        
        .valor {
            text-align: right;
            font-family: 'Roboto Mono', monospace;
        }
        
        .movimento-item {
            margin: 5px 0;
        }
        
        .btn-excluir {
            background-color: var(--danger-color);
            color: white;
            border: none;
            border-radius: var(--border-radius);
            padding: 5px 8px;
            cursor: pointer;
            font-size: 0.8rem;
            transition: background-color 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        
        .btn-excluir:hover {
            background-color: #d91a4d;
        }
        
        .saldo-container {
            margin: 20px 0;
            padding: 15px;
            background-color: white;
            border-radius: var(--border-radius);
            box-shadow: var(--box-shadow);
            text-align: center;
        }
        
        .saldo-valor {
            font-size: 1.4rem;
            margin-top: 5px;
        }
        
        .navigation-links {
            display: flex;
            gap: 10px;
            margin-top: 20px;
            flex-wrap: wrap;
            justify-content: center;
        }
        
        .navigation-links a {
            color: var(--primary-color);
            text-decoration: none;
            padding: 8px 12px;
            border-radius: var(--border-radius);
            border: 1px solid var(--primary-color);
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        
        .navigation-links a:hover {
            background-color: #f0f2ff;
        }
        
        @media (max-width: 768px) {
            body {
                margin: 10px;
            }
            
            table {
                display: block;
                overflow-x: auto;
            }
            
            th, td {
                width: auto !important;
            }
            
            .navigation-links {
                flex-direction: column;
            }
            
            .navigation-links a {
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <h1><i class="fas fa-cash-register"></i> Movimentações do Caixa</h1>

    <%
    String jdbcUrl = "jdbc:mariadb://localhost:3306/Rosbea";
    String dbUser = "paulo";
    String dbPassword = "6421";

    Connection connection = null;
    PreparedStatement preparedStatement = null;
    ResultSet resultSet = null;
    double saldo = 0.0;
    double totalEntradas = 0.0;
    double totalSaidas = 0.0;

    // Processar exclusão se houver parâmetro
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("excluir_id") != null) {
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            connection = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);
            
            String deleteSql = "DELETE FROM caixa WHERE id = ?";
            preparedStatement = connection.prepareStatement(deleteSql);
            preparedStatement.setInt(1, Integer.parseInt(request.getParameter("excluir_id")));
            int rowsAffected = preparedStatement.executeUpdate();
            
            if (rowsAffected > 0) {
                out.println("<div class='mensagem sucesso' style='margin: 20px auto; max-width: 500px;'>"
                    + "<i class='fas fa-check-circle'></i> Movimento excluído com sucesso!"
                    + "</div>");
            }
        } catch (Exception e) {
            out.println("<div class='mensagem erro' style='margin: 20px auto; max-width: 500px;'>"
                + "<i class='fas fa-exclamation-circle'></i> Erro ao excluir movimento: " + e.getMessage()
                + "</div>");
        } finally {
            try { if (preparedStatement != null) preparedStatement.close(); } catch (Exception e) {}
            try { if (connection != null) connection.close(); } catch (Exception e) {}
        }
    }

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        connection = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

        // Primeiro obtemos todas as entradas
        String sqlEntradas = "SELECT * FROM caixa WHERE tipo = 'entrada' ORDER BY data_movimentacao DESC, id DESC";
        preparedStatement = connection.prepareStatement(sqlEntradas);
        ResultSet rsEntradas = preparedStatement.executeQuery();
        
        // Depois obtemos todas as saídas
        String sqlSaidas = "SELECT * FROM caixa WHERE tipo = 'saida' ORDER BY data_movimentacao DESC, id DESC";
        preparedStatement = connection.prepareStatement(sqlSaidas);
        ResultSet rsSaidas = preparedStatement.executeQuery();
        
        // Calculamos totais
        String sqlTotais = "SELECT " +
                          "SUM(CASE WHEN tipo = 'entrada' THEN valor ELSE 0 END) as total_entradas, " +
                          "SUM(CASE WHEN tipo = 'saida' THEN valor ELSE 0 END) as total_saidas " +
                          "FROM caixa";
        preparedStatement = connection.prepareStatement(sqlTotais);
        ResultSet rsTotais = preparedStatement.executeQuery();
        
        if (rsTotais.next()) {
            totalEntradas = rsTotais.getDouble("total_entradas");
            totalSaidas = rsTotais.getDouble("total_saidas");
            saldo = totalEntradas - totalSaidas;
        }
    %>
    
    <table>
        <tr>
            <th class="data-header">Data/Hora</th>
            <th class="entrada-header"><i class="fas fa-arrow-down"></i> Entradas</th>
            <th class="saida-header"><i class="fas fa-arrow-up"></i> Saídas</th>
            <th class="acoes-header"><i class="fas fa-cog"></i> Ações</th>
        </tr>
        
        <%
        // Vamos percorrer simultaneamente entradas e saídas
        boolean hasEntrada = rsEntradas.next();
        boolean hasSaida = rsSaidas.next();
        
        while (hasEntrada || hasSaida) {
            String dataEntrada = "";
            String descricaoEntrada = "";
            String valorEntrada = "";
            String nrPedidoEntrada = "";
            int idEntrada = 0;
            
            String dataSaida = "";
            String descricaoSaida = "";
            String valorSaida = "";
            String nrPedidoSaida = "";
            int idSaida = 0;
            
            // Pega a data mais recente entre entrada e saída
            String currentDate = "";
            
            if (hasEntrada) {
                dataEntrada = rsEntradas.getString("data_movimentacao");
                descricaoEntrada = rsEntradas.getString("descricao");
                valorEntrada = String.format("%.2f", rsEntradas.getDouble("valor"));
                nrPedidoEntrada = rsEntradas.getString("nr_pedido") != null ? rsEntradas.getString("nr_pedido") : "";
                idEntrada = rsEntradas.getInt("id");
                currentDate = dataEntrada;
            }
            
            if (hasSaida) {
                dataSaida = rsSaidas.getString("data_movimentacao");
                descricaoSaida = rsSaidas.getString("descricao");
                valorSaida = String.format("%.2f", rsSaidas.getDouble("valor"));
                nrPedidoSaida = rsSaidas.getString("nr_pedido") != null ? rsSaidas.getString("nr_pedido") : "";
                idSaida = rsSaidas.getInt("id");
                
                // Se não tiver entrada ou se a saída for mais recente
                if (currentDate.isEmpty() || dataSaida.compareTo(currentDate) > 0) {
                    currentDate = dataSaida;
                }
            }
        %>
        <tr>
            <td class="data-cell"><%= currentDate %></td>
            
            <% if (hasEntrada && dataEntrada.equals(currentDate)) { %>
                <td class="entrada-cell">
                    <div class="movimento-item"><strong><%= descricaoEntrada %></strong></div>
                    <div class="movimento-item valor positivo">R$ <%= valorEntrada %></div>
                    <% if (!nrPedidoEntrada.isEmpty()) { %>
                        <div class="movimento-item">Pedido: <%= nrPedidoEntrada %></div>
                    <% } %>
                    <% hasEntrada = rsEntradas.next(); %>
                </td>
            <% } else { %>
                <td class="entrada-cell">-</td>
            <% } %>
            
            <% if (hasSaida && dataSaida.equals(currentDate)) { %>
                <td class="saida-cell">
                    <div class="movimento-item"><strong><%= descricaoSaida %></strong></div>
                    <div class="movimento-item valor negativo">R$ <%= valorSaida %></div>
                    <% if (!nrPedidoSaida.isEmpty()) { %>
                        <div class="movimento-item">Pedido: <%= nrPedidoSaida %></div>
                    <% } %>
                    <% hasSaida = rsSaidas.next(); %>
                </td>
            <% } else { %>
                <td class="saida-cell">-</td>
            <% } %>
            
            <td class="acoes-cell">
                <form method="post" style="margin: 0; display: inline;">
                    <% if (hasEntrada && dataEntrada.equals(currentDate)) { %>
                        <input type="hidden" name="excluir_id" value="<%= idEntrada %>">
                        <button type="submit" class="btn-excluir" onclick="return confirm('Tem certeza que deseja excluir esta entrada?')">
                            <i class="fas fa-trash-alt"></i> Excluir
                        </button>
                    <% } else if (hasSaida && dataSaida.equals(currentDate)) { %>
                        <input type="hidden" name="excluir_id" value="<%= idSaida %>">
                        <button type="submit" class="btn-excluir" onclick="return confirm('Tem certeza que deseja excluir esta saída?')">
                            <i class="fas fa-trash-alt"></i> Excluir
                        </button>
                    <% } else { %>
                        -
                    <% } %>
                </form>
            </td>
        </tr>
        <%
        }
        %>
    </table>

    <div class="saldo-container">
        <h3>Resumo Financeiro</h3>
        <p>Total de Entradas: <span class="positivo">R$ <%= String.format("%.2f", totalEntradas) %></span></p>
        <p>Total de Saídas: <span class="negativo">R$ <%= String.format("%.2f", totalSaidas) %></span></p>
        <div class="saldo-valor <%= saldo >= 0 ? "positivo" : "negativo" %>">
            Saldo Atual: R$ <%= String.format("%.2f", saldo) %>
        </div>
    </div>

    <%
    } catch (Exception e) {
        out.println("<p>Erro: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        try {
            if (resultSet != null) resultSet.close();
            if (preparedStatement != null) preparedStatement.close();
            if (connection != null) connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    %>

    <div class="navigation-links">
        <a href="registrar_saida.jsp"><i class="fas fa-minus-circle"></i> Registrar Despesa</a>
        <a href="registrar_entrada.jsp"><i class="fas fa-plus-circle"></i> Registrar Receita</a>
        <a href="caixa.jsp"><i class="fas fa-home"></i> Voltar ao Início</a>
    </div>
</body>
</html>