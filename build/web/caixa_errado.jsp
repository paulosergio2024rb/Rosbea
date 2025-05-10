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
        /* SEU CSS ORIGINAL - MANTIDO INTEGRALMENTE */
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
            margin: 0;
            padding: 20px;
            background-color: #f5f7fa;
            color: #333;
            line-height: 1.6;
        }
        
        .container {
            max-width: 1000px;
            margin: 0 auto;
        }
        
        .card {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 25px;
            box-shadow: var(--box-shadow);
            margin-bottom: 20px;
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
        
        .info-caixa {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: var(--border-radius);
            margin-bottom: 20px;
            border-left: 4px solid var(--primary-color);
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            box-shadow: var(--box-shadow);
        }
        
        th {
            background-color: var(--primary-color);
            color: white;
            padding: 12px;
            text-align: left;
        }
        
        td {
            padding: 10px 12px;
            border-bottom: 1px solid #eee;
        }
        
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        
        tr:hover {
            background-color: #f1f1f1;
        }
        
        .positivo {
            color: green;
            font-weight: bold;
        }
        
        .negativo {
            color: red;
            font-weight: bold;
        }
        
        .navigation-links {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }
        
        .btn {
            padding: 10px 15px;
            border: none;
            border-radius: var(--border-radius);
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            font-size: 0.9rem;
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            color: white;
        }
        
        .btn-primary:hover {
            background-color: #3a56d4;
        }
        
        .btn-success {
            background-color: var(--success-color);
            color: white;
        }
        
        .btn-danger {
            background-color: var(--danger-color);
            color: white;
        }
        
        .mensagem {
            padding: 12px;
            margin: 15px 0;
            border-radius: var(--border-radius);
            font-weight: 500;
        }
        
        .sucesso {
            background-color: #e6f7ee;
            color: #0a8f4e;
            border-left: 3px solid #0a8f4e;
        }
        
        .erro {
            background-color: #feecef;
            color: #d91a4d;
            border-left: 3px solid #d91a4d;
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 10px;
            }
            
            .card {
                padding: 15px;
            }
            
            table {
                display: block;
                overflow-x: auto;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1><i class="fas fa-cash-register"></i> Movimentações do Caixa</h1>
        
        <%
        // Conexão e verificação do caixa (NOVO BLOCO ADICIONADO)
        String jdbcUrl = "jdbc:mariadb://localhost:3306/Rosbea";
        String dbUser = "paulo";
        String dbPassword = "6421";
        
        boolean caixaAberto = false;
        String dataAbertura = "";
        double valorInicial = 0;
        int idCaixaAtual = -1;
        
        try (Connection conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword)) {
            String sql = "SELECT id_caixa, data_abertura, valor_inicial FROM caixa WHERE status = 'aberto' LIMIT 1";
            try (PreparedStatement stmt = conn.prepareStatement(sql);
                 ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    caixaAberto = true;
                    idCaixaAtual = rs.getInt("id_caixa");
                    dataAbertura = rs.getString("data_abertura");
                    valorInicial = rs.getDouble("valor_inicial");
                }
            }
        } catch (SQLException e) {
            out.println("<div class='mensagem erro'>Erro ao verificar caixa: " + e.getMessage() + "</div>");
        }
        %>
        
        <!-- SEU LAYOUT ORIGINAL - MANTIDO -->
        <div class="card">
            <% if (caixaAberto) { %>
            <div class="info-caixa">
                <p><strong>Caixa aberto desde:</strong> <%= dataAbertura %></p>
                <p><strong>Valor inicial:</strong> R$ <%= String.format("%.2f", valorInicial) %></p>
            </div>
            <% } else { %>
            <div class="mensagem erro">
                <i class="fas fa-exclamation-circle"></i> ATENÇÃO: Caixa fechado. Não é possível registrar movimentos.
                <a href="abrir_caixa.jsp" class="btn btn-success" style="margin-left: 10px;">
                    <i class="fas fa-lock-open"></i> Abrir Caixa
                </a>
            </div>
            <% } %>
            
            <!-- BOTÕES ORIGINAIS - MANTIDOS -->
            <div class="navigation-links">
                <a href="registrar_entrada.jsp" class="btn btn-success">
                    <i class="fas fa-plus-circle"></i> Nova Entrada
                </a>
                <a href="registrar_saida.jsp" class="btn btn-danger">
                    <i class="fas fa-minus-circle"></i> Nova Saída
                </a>
                <% if (caixaAberto) { %>
                <a href="fechar_caixa.jsp" class="btn btn-primary" 
                   onclick="return confirm('Tem certeza que deseja fechar o caixa?')">
                    <i class="fas fa-lock"></i> Fechar Caixa
                </a>
                <% } %>
                <a href="inicio.jsp" class="btn btn-primary">
                    <i class="fas fa-home"></i> Voltar
                </a>
            </div>
            
            <!-- TABELA DE MOVIMENTAÇÕES ORIGINAL - MANTIDA -->
            <table>
                <thead>
                    <tr>
                        <th>Data/Hora</th>
                        <th>Descrição</th>
                        <th>Tipo</th>
                        <th>Valor</th>
                        <th>Pedido</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    if (caixaAberto) {
                        try (Connection conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword)) {
                            String sqlMov = "SELECT data_movimentacao, descricao, tipo, valor, id_pedido " +
                                          "FROM movimentacao_caixa WHERE id_caixa = ? ORDER BY data_movimentacao DESC";
                            try (PreparedStatement stmt = conn.prepareStatement(sqlMov)) {
                                stmt.setInt(1, idCaixaAtual);
                                try (ResultSet rs = stmt.executeQuery()) {
                                    while (rs.next()) {
                                        String tipo = rs.getString("tipo");
                                        String cor = tipo.equals("entrada") ? "positivo" : "negativo";
                    %>
                    <tr>
                        <td><%= rs.getString("data_movimentacao") %></td>
                        <td><%= rs.getString("descricao") %></td>
                        <td class="<%= cor %>"><%= tipo %></td>
                        <td class="<%= cor %>">
                            <%= tipo.equals("entrada") ? "+" : "-" %> R$ <%= String.format("%.2f", rs.getDouble("valor")) %>
                        </td>
                        <td><%= rs.getString("id_pedido") != null ? rs.getString("id_pedido") : "-" %></td>
                    </tr>
                    <%
                                    }
                                }
                            }
                        } catch (SQLException e) {
                            out.println("<tr><td colspan='5' class='erro'>Erro ao carregar movimentos: " + e.getMessage() + "</td></tr>");
                        }
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>