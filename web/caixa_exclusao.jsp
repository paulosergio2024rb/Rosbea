<%@ page import="java.sql.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Buscar e Excluir Movimentos</title>
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
        
        .form-group {
            margin-bottom: 15px;
        }
        
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
        }
        
        input[type="text"],
        input[type="date"],
        select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: var(--border-radius);
            font-family: 'Roboto', sans-serif;
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
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            color: white;
        }
        
        .btn-primary:hover {
            background-color: #3a56d4;
        }
        
        .btn-danger {
            background-color: var(--danger-color);
            color: white;
        }
        
        .btn-danger:hover {
            background-color: #d91a4d;
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
        
        .acoes-cell {
            white-space: nowrap;
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
        <h1><i class="fas fa-search-dollar"></i> Buscar e Excluir Movimentos</h1>
        
        <div class="card">
            <form method="get" action="">
                <div class="form-group">
                    <label for="tipo">Tipo de Movimento:</label>
                    <select id="tipo" name="tipo">
                        <option value="">Todos</option>
                        <option value="entrada">Entrada</option>
                        <option value="saida">Saída</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="data_inicio">Data Início:</label>
                    <input type="date" id="data_inicio" name="data_inicio">
                </div>
                
                <div class="form-group">
                    <label for="data_fim">Data Fim:</label>
                    <input type="date" id="data_fim" name="data_fim">
                </div>
                
                <div class="form-group">
                    <label for="nr_pedido">Número do Pedido:</label>
                    <input type="text" id="nr_pedido" name="nr_pedido" placeholder="Opcional">
                </div>
                
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-search"></i> Buscar
                </button>
            </form>
        </div>
        
        <%
        // Processar exclusão se for uma requisição POST
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String idExcluir = request.getParameter("id_excluir");
            if (idExcluir != null && !idExcluir.isEmpty()) {
                String jdbcUrl = "jdbc:mariadb://localhost:3306/Rosbea";
                String dbUser = "paulo";
                String dbPassword = "6421";
                
                Connection connection = null;
                PreparedStatement preparedStatement = null;
                
                try {
                    Class.forName("org.mariadb.jdbc.Driver");
                    connection = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);
                    
                    String sql = "DELETE FROM movimentacao_caixa WHERE id_movimentacao = ?";
                    preparedStatement = connection.prepareStatement(sql);
                    preparedStatement.setInt(1, Integer.parseInt(idExcluir));
                    int rowsAffected = preparedStatement.executeUpdate();
                    
                    if (rowsAffected > 0) {
                        out.println("<div class='mensagem sucesso'>");
                        out.println("<i class='fas fa-check-circle'></i> Movimento excluído com sucesso!");
                        out.println("</div>");
                    }
                } catch (Exception e) {
                    out.println("<div class='mensagem erro'>");
                    out.println("<i class='fas fa-exclamation-circle'></i> Erro ao excluir movimento: " + e.getMessage());
                    out.println("</div>");
                } finally {
                    try { if (preparedStatement != null) preparedStatement.close(); } catch (Exception e) {}
                    try { if (connection != null) connection.close(); } catch (Exception e) {}
                }
            }
        }
        
        // Buscar movimentos conforme filtros
        String tipo = request.getParameter("tipo");
        String dataInicio = request.getParameter("data_inicio");
        String dataFim = request.getParameter("data_fim");
        String nrPedido = request.getParameter("nr_pedido");
        
        boolean temFiltro = tipo != null || dataInicio != null || dataFim != null || nrPedido != null;
        
        if (temFiltro) {
            String jdbcUrl = "jdbc:mariadb://localhost:3306/Rosbea";
            String dbUser = "paulo";
            String dbPassword = "6421";
            
            Connection connection = null;
            PreparedStatement preparedStatement = null;
            ResultSet resultSet = null;
            
            try {
                Class.forName("org.mariadb.jdbc.Driver");
                connection = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);
                
                // Construir a query dinamicamente
                StringBuilder sql = new StringBuilder("SELECT * FROM vw_movimentacao_caixa_excluir WHERE 1=1");
                List<String> params = new ArrayList<>();
                
                if (tipo != null && !tipo.isEmpty()) {
                    sql.append(" AND tipo = ?");
                    params.add(tipo);
                }
                
                if (dataInicio != null && !dataInicio.isEmpty()) {
                    sql.append(" AND data_movimentacao >= ?");
                    params.add(dataInicio);
                }
                
                if (dataFim != null && !dataFim.isEmpty()) {
                    sql.append(" AND data_movimentacao <= ?");
                    params.add(dataFim + " 23:59:59"); // Para incluir todo o dia
                }
                
                if (nrPedido != null && !nrPedido.isEmpty()) {
                    sql.append(" AND id_pedido = ?");
                    params.add(nrPedido);
                }
                
                sql.append(" ORDER BY data_movimentacao DESC, id_movimentacao DESC");
                
                preparedStatement = connection.prepareStatement(sql.toString());
                
                // Preencher os parâmetros
                for (int i = 0; i < params.size(); i++) {
                    preparedStatement.setString(i + 1, params.get(i));
                }
                
                resultSet = preparedStatement.executeQuery();
                
                if (resultSet.next()) {
        %>
                <div class="card">
                    <h2><i class="fas fa-list-ol"></i> Resultados da Busca</h2>
                    
                    <table>
                        <tr>
                            <th>Data</th>
                            <th>Tipo</th>
                            <th>Descrição</th>
                            <th>Valor</th>
                            <th>Pedido</th>
                            <th>Ações</th>
                        </tr>
                        
                        <%
                        do {
                            int id = resultSet.getInt("id_movimentacao");
                            String data = resultSet.getString("data_movimentacao");
                            String movTipo = resultSet.getString("tipo");
                            String descricao = resultSet.getString("descricao");
                            double valor = resultSet.getDouble("valor");
                            String movNrPedido = resultSet.getString("id_pedido");
                        %>
                        <tr>
                            <td><%= data %></td>
                            <td><%= movTipo %></td>
                            <td><%= descricao %></td>
                            <td class="<%= "entrada".equals(movTipo) ? "positivo" : "negativo" %>">
                                R$ <%= String.format("%.2f", valor) %>
                            </td>
                            <td><%= movNrPedido != null ? movNrPedido : "-" %></td>
                            <td class="acoes-cell">
                                <form method="post" style="display: inline;">
                                    <input type="hidden" name="id_excluir" value="<%= id %>">
                                    <button type="submit" class="btn btn-danger" 
                                            onclick="return confirm('Tem certeza que deseja excluir este movimento?')">
                                        <i class="fas fa-trash-alt"></i> Excluir
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <%
                        } while (resultSet.next());
                        %>
                    </table>
                </div>
        <%
                } else {
                    out.println("<div class='mensagem'>");
                    out.println("<i class='fas fa-info-circle'></i> Nenhum movimento encontrado com os filtros informados.");
                    out.println("</div>");
                }
            } catch (Exception e) {
                out.println("<div class='mensagem erro'>");
                out.println("<i class='fas fa-exclamation-circle'></i> Erro ao buscar movimentos: " + e.getMessage());
                out.println("</div>");
            } finally {
                try { if (resultSet != null) resultSet.close(); } catch (Exception e) {}
                try { if (preparedStatement != null) preparedStatement.close(); } catch (Exception e) {}
                try { if (connection != null) connection.close(); } catch (Exception e) {}
            }
        }
        %>
        
        <div style="text-align: center; margin-top: 20px;">
            <a href="caixa.jsp" class="btn btn-primary">
                <i class="fas fa-home"></i> Voltar ao Início
            </a>
        </div>
    </div>
</body>
</html>