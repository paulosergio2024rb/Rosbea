<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Movimentações do Caixa</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body {
            background-color: #f8f9fa;
            padding: 20px;
        }
        .caixa-header {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            padding: 20px;
            margin-bottom: 20px;
        }
        .table-container {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            padding: 20px;
            margin-bottom: 20px;
        }
        .entrada {
            color: #28a745;
            font-weight: bold;
        }
        .saida {
            color: #dc3545;
            font-weight: bold;
        }
        .saldo-container {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            padding: 20px;
            margin-bottom: 20px;
        }
        .saldo-total {
            font-size: 1.2rem;
            font-weight: bold;
        }
        .btn-action {
            margin-right: 10px;
            margin-bottom: 10px;
        }
        .table th {
            background-color: #f8f9fa;
        }
        .total-row {
            font-weight: bold;
            background-color: #f8f9fa;
        }
        /* NOVO ESTILO PARA OS BADGES */
        .badge-tipo {
            min-width: 70px;
            display: inline-block;
            text-align: center;
            padding: 5px 10px;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h1><i class="fas fa-cash-register me-2"></i>Movimentações do Caixa</h1>
            <div>
                <a href="registrar_entrada.jsp" class="btn btn-success btn-action">
                    <i class="fas fa-plus-circle me-1"></i>Nova Entrada
                </a>
                <a href="registrar_saida.jsp" class="btn btn-danger btn-action">
                    <i class="fas fa-minus-circle me-1"></i>Nova Saída
                </a>
                <a href="caixa.jsp" class="btn btn-primary btn-action">
                    <i class="fas fa-home me-1"></i>Voltar
                </a>
            </div>
        </div>

        <%
        String jdbcUrl = "jdbc:mariadb://localhost:3306/Rosbea";
        String dbUser = "paulo";
        String dbPassword = "6421";

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        ResultSet rsCaixa = null;
        
        double totalEntradas = 0.0;
        double totalSaidas = 0.0;
        double saldo = 0.0;
        
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);
            
            // Primeiro obtemos os dados do caixa aberto
            stmt = conn.prepareStatement("SELECT id_caixa, data_abertura, valor_inicial FROM caixa WHERE status = 'aberto' LIMIT 1");
            rsCaixa = stmt.executeQuery();
            
            int idCaixaAtual = -1;
            String dataAbertura = "";
            double valorInicial = 0.0;
            
            if(rsCaixa.next()) {
                idCaixaAtual = rsCaixa.getInt("id_caixa");
                dataAbertura = rsCaixa.getString("data_abertura");
                valorInicial = rsCaixa.getDouble("valor_inicial");
            }
            rsCaixa.close();
        %>
        
        <% if(idCaixaAtual != -1) { %>
            <div class="caixa-header">
                <div class="row">
                    <div class="col-md-6">
                        <p class="mb-1"><strong>Caixa aberto desde:</strong> <%= dataAbertura %></p>
                    </div>
                    <div class="col-md-6">
                        <p class="mb-1"><strong>Valor inicial:</strong> R$ <%= String.format("%.2f", valorInicial) %></p>
                    </div>
                </div>
            </div>
        <% } %>

        <div class="table-container">
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead class="table-light">
                        <tr>
                            <th>Data/Hora</th>
                            <th>Descrição</th>
                            <th>Tipo</th>
                            <th>Pedido</th>
                            <th class="text-end">Valor</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        // Consulta de movimentações
                        String sql = "SELECT mc.*, COALESCE(p.id, '') as nr_pedido " +
                                    "FROM movimentacao_caixa mc " +
                                    "LEFT JOIN pedido p ON mc.id_pedido = p.id " +
                                    (idCaixaAtual != -1 ? "WHERE mc.id_caixa = ? " : "") +
                                    "ORDER BY mc.data_movimentacao DESC";
                        
                        stmt = conn.prepareStatement(sql);
                        if(idCaixaAtual != -1) {
                            stmt.setInt(1, idCaixaAtual);
                        }
                        rs = stmt.executeQuery();
                        
                        // Resetar totais
                        totalEntradas = 0.0;
                        totalSaidas = 0.0;
                        
                        while(rs.next()) {
                            String data = rs.getString("data_movimentacao");
                            String descricao = rs.getString("descricao");
                            double valor = rs.getDouble("valor");
                            String tipo = rs.getString("tipo");
                            String nrPedido = rs.getString("nr_pedido");
                            
                            // Calcular totais
                            if("entrada".equals(tipo)) {
                                totalEntradas += valor;
                            } else {
                                totalSaidas += valor;
                            }
                        %>
                        <tr>
                            <td><%= data %></td>
                            <td><%= descricao %></td>
                            <td>
                                <span class="badge <%= tipo.equals("entrada") ? "bg-success" : "bg-danger" %> badge-tipo">
                                    <%= tipo.equals("entrada") ? "Entrada" : "Saída" %>
                                </span>
                            </td>
                            <td><%= nrPedido.isEmpty() ? "-" : nrPedido %></td>
                            <td class="text-end <%= tipo.equals("entrada") ? "entrada" : "saida" %>">
                                <%= tipo.equals("entrada") ? "+" : "-" %> R$ <%= String.format("%.2f", valor) %>
                            </td>
                        </tr>
                        <%
                        }
                        
                        // Calcular saldo final
                        saldo = totalEntradas - totalSaidas;
                        %>
                        
                        <!-- Linha de totais -->
                        <tr class="total-row">
                            <td colspan="4" class="text-end"><strong>Total Entradas:</strong></td>
                            <td class="text-end entrada">R$ <%= String.format("%.2f", totalEntradas) %></td>
                        </tr>
                        <tr class="total-row">
                            <td colspan="4" class="text-end"><strong>Total Saídas:</strong></td>
                            <td class="text-end saida">R$ <%= String.format("%.2f", totalSaidas) %></td>
                        </tr>
                        <tr class="total-row">
                            <td colspan="4" class="text-end"><strong>Saldo Final:</strong></td>
                            <td class="text-end <%= saldo >= 0 ? "entrada" : "saida" %>">
                                R$ <%= String.format("%.2f", saldo) %>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="saldo-container">
            <div class="row">
                <div class="col-md-4">
                    <div class="card border-success mb-3">
                        <div class="card-body text-success">
                            <h5 class="card-title">Total Entradas</h5>
                            <p class="card-text display-6">R$ <%= String.format("%.2f", totalEntradas) %></p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card border-danger mb-3">
                        <div class="card-body text-danger">
                            <h5 class="card-title">Total Saídas</h5>
                            <p class="card-text display-6">R$ <%= String.format("%.2f", totalSaidas) %></p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card <%= saldo >= 0 ? "border-success text-success" : "border-danger text-danger" %> mb-3">
                        <div class="card-body">
                            <h5 class="card-title">Saldo Final</h5>
                            <p class="card-text display-6">R$ <%= String.format("%.2f", saldo) %></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%
        } catch(Exception e) {
        %>
            <div class="alert alert-danger" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>Erro: <%= e.getMessage() %>
            </div>
        <%
        } finally {
            try {
                if(rs != null) rs.close();
                if(stmt != null) stmt.close();
                if(conn != null) conn.close();
            } catch(SQLException e) {
                e.printStackTrace();
            }
        }
        %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>