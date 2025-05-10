<%@ page import="java.sql.*, java.text.DecimalFormat, java.util.Date, java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Controle de Vencimentos</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
        :root {
            --primary-color: #4e73df;
            --success-color: #1cc88a;
            --danger-color: #e74a3b;
            --warning-color: #f6c23e;
            --light-bg: #f8f9fc;
        }
        
        body {
            background-color: #f5f7fb;
            font-family: 'Nunito', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
        }
        
        .card {
            border: none;
            border-radius: 0.35rem;
            box-shadow: 0 0.15rem 1.75rem 0 rgba(58, 59, 69, 0.15);
        }
        
        .table-responsive {
            overflow-x: auto;
        }
        
        .table {
            margin-bottom: 0;
        }
        
        .table th {
            border-top: none;
            font-weight: 600;
            color: #5a5c69;
            background-color: #f8f9fc;
            text-transform: uppercase;
            font-size: 0.7rem;
            letter-spacing: 0.08em;
        }
        
        .status-badge {
            font-size: 0.75rem;
            font-weight: 700;
            padding: 0.35em 0.65em;
            border-radius: 0.25rem;
        }
        
        .status-pago {
            background-color: rgba(28, 200, 138, 0.1);
            color: var(--success-color);
        }
        
        .status-vencido {
            background-color: rgba(231, 74, 59, 0.1);
            color: var(--danger-color);
        }
        
        .status-pendente {
            background-color: rgba(246, 194, 62, 0.1);
            color: var(--warning-color);
        }
        
        .search-box {
            position: relative;
        }
        
        .search-box .form-control {
            padding-left: 2.5rem;
            border-radius: 0.35rem;
        }
        
        .search-box .bi-search {
            position: absolute;
            top: 50%;
            left: 1rem;
            transform: translateY(-50%);
            color: #b7b9cc;
        }
        
        .valor-total {
            font-weight: 700;
            color: #2e59d9;
        }
        
        .valor-parcela {
            font-weight: 600;
            color: #858796;
        }
        
        .action-btn {
            padding: 0.25rem 0.5rem;
            font-size: 0.875rem;
        }
    </style>
</head>
<body>
    <div class="container-fluid py-4">
        <div class="d-sm-flex align-items-center justify-content-between mb-4">
            <h1 class="h3 mb-0 text-gray-800">
                <i class="bi bi-calendar-check me-2"></i>Controle de Vencimentos
            </h1>
            <div class="d-none d-sm-inline-block">
                <span class="badge bg-primary">
                    <i class="bi bi-calendar me-1"></i>
                    <%= new SimpleDateFormat("dd/MM/yyyy").format(new Date()) %>
                </span>
            </div>
        </div>

        <div class="card shadow mb-4">
            <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                <h6 class="m-0 font-weight-bold text-primary">Lista de Vencimentos</h6>
                <div class="search-box">
                    <i class="bi bi-search"></i>
                    <form method="get" class="d-inline">
                        <input type="text" class="form-control" name="nr_pedido_busca" 
                               placeholder="Buscar por Nº Pedido" 
                               value="<%= request.getParameter("nr_pedido_busca") != null ? request.getParameter("nr_pedido_busca") : "" %>">
                    </form>
                </div>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Pedido</th>
                                <th>Vencimento</th>
                                <th>Valor Total</th>
                                <th>Parcelas</th>
                                <th>Valor Parcela</th>
                                <th>Status</th>
                                <th>Pagamento</th>
                                <th>Ações</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection conn = null;
                                PreparedStatement stmt = null;
                                ResultSet rs = null;
                                DecimalFormat df = new DecimalFormat("#,##0.00");
                                Date hoje = new Date();

                                try {
                                    Class.forName("org.mariadb.jdbc.Driver");
                                    conn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

                                    String sql = "SELECT * FROM vencimentos";
                                    String nrPedidoBusca = request.getParameter("nr_pedido_busca");
                                    
                                    if (nrPedidoBusca != null && !nrPedidoBusca.isEmpty()) {
                                        sql += " WHERE nr_pedido = ? ORDER BY data_pedidovcto";
                                        stmt = conn.prepareStatement(sql);
                                        stmt.setString(1, nrPedidoBusca);
                                    } else {
                                        stmt = conn.prepareStatement(sql + " ORDER BY data_pedidovcto DESC LIMIT 100");
                                    }

                                    rs = stmt.executeQuery();

                                    while (rs.next()) {
                                        int id = rs.getInt("id");
                                        int nrPedido = rs.getInt("nr_pedido");
                                        Date dataVencimento = rs.getDate("data_pedidovcto");
                                        double valorTotalPedido = rs.getDouble("valor_ped");
                                        double valorParcela = rs.getDouble("valor_parcela");
                                        int qtdParcelas = rs.getInt("quantidade_parcelas");
                                        Date dataPagamento = rs.getDate("data_pagto");
                                        String pgtoStatus = rs.getString("pgto");
                                        
                                        String statusClass = "";
                                        String statusText = "";
                                        
                                        if ("Pago".equalsIgnoreCase(pgtoStatus)) {
                                            statusClass = "status-pago";
                                            statusText = "Pago";
                                        } else if (dataVencimento != null && dataVencimento.before(hoje)) {
                                            statusClass = "status-vencido";
                                            statusText = "Vencido";
                                        } else {
                                            statusClass = "status-pendente";
                                            statusText = "Pendente";
                                        }
                            %>
                            <tr>
                                <td><%= id %></td>
                                <td><strong>#<%= nrPedido %></strong></td>
                                <td><%= dataVencimento != null ? new SimpleDateFormat("dd/MM/yyyy").format(dataVencimento) : "-" %></td>
                                <td class="valor-total">R$ <%= df.format(valorTotalPedido) %></td>
                                <td><%= qtdParcelas > 0 ? qtdParcelas + "x" : "À vista" %></td>
                                <td class="valor-parcela">R$ <%= df.format(valorParcela) %></td>
                                <td><span class="status-badge <%= statusClass %>"><%= statusText %></span></td>
                                <td><%= dataPagamento != null ? new SimpleDateFormat("dd/MM/yyyy").format(dataPagamento) : "-" %></td>
                                <td>
                                    <a href="editar_vencimento.jsp?id=<%= id %>" class="btn btn-sm btn-outline-primary action-btn" title="Editar">
                                        <i class="bi bi-pencil"></i>
                                    </a>
                                </td>
                            </tr>
                            <%
                                    }
                                } catch (Exception e) {
                            %>
                            <tr>
                                <td colspan="9" class="text-center text-danger py-3">
                                    <i class="bi bi-exclamation-triangle-fill"></i> Erro ao carregar dados: <%= e.getMessage() %>
                                </td>
                            </tr>
                            <%
                                } finally {
                                    if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                    if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
                                    if (conn != null) try { conn.close(); } catch (SQLException e) {}
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="card-footer small text-muted">
                Atualizado em <%= new SimpleDateFormat("dd/MM/yyyy HH:mm").format(new Date()) %>
                <span class="float-end">
                    Total de registros: 
                    <%
                        try {
                            Connection countConn = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");
                            Statement countStmt = countConn.createStatement();
                            ResultSet countRs = countStmt.executeQuery("SELECT COUNT(*) as total FROM vencimentos");
                            if (countRs.next()) {
                                out.print(countRs.getInt("total"));
                            }
                            countRs.close();
                            countStmt.close();
                            countConn.close();
                        } catch (Exception e) {
                            out.print("N/D");
                        }
                    %>
                </span>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto-submit do formulário de busca quando digitar
        document.querySelector('[name="nr_pedido_busca"]').addEventListener('keyup', function(e) {
            if (e.key === 'Enter') {
                this.form.submit();
            }
        });
        
        // Tooltips
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[title]'));
        var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl);
        });
    </script>
</body>
</html>