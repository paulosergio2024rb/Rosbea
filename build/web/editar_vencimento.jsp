<%@ page import="java.sql.*, java.text.DecimalFormat, java.util.Date, java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String idParam = request.getParameter("id");
    if (idParam == null || idParam.isEmpty()) {
        response.sendRedirect("exibir_vencimentos.jsp?erro=id_ausente");
        return;
    }
    int idVencimento = Integer.parseInt(idParam);

    Connection connection = null;
    PreparedStatement preparedStatement = null;
    ResultSet resultSet = null;

    // Variáveis para armazenar os dados
    int prazoAtual = 0;
    double valorParcelaAtual = 0;
    double valorTotalPedido = 0;
    int nrPedido = 0;
    String dataVencimentoStr = "";
    Date dataVencimento = null;
    Date dataPagamento = null;
    int quantidadeParcelas = 0;
    String statusCalculado = "Pendente";
    DecimalFormat df = new DecimalFormat("#,##0.00");

    try {
        Class.forName("org.mariadb.jdbc.Driver");
        connection = DriverManager.getConnection("jdbc:mariadb://localhost:3306/Rosbea", "paulo", "6421");

        // Consulta para obter todos os dados necessários
        String sql = "SELECT * FROM vencimentos WHERE id = ?";

        preparedStatement = connection.prepareStatement(sql);
        preparedStatement.setInt(1, idVencimento);
        resultSet = preparedStatement.executeQuery();

        if (resultSet.next()) {
            prazoAtual = resultSet.getInt("prazo");
            valorParcelaAtual = resultSet.getDouble("valor_parcela");
            valorTotalPedido = resultSet.getDouble("valor_ped");
            nrPedido = resultSet.getInt("nr_pedido");
            dataVencimentoStr = resultSet.getString("data_pedidovcto");
            dataVencimento = resultSet.getDate("data_pedidovcto");
            dataPagamento = resultSet.getDate("data_pagto");
            quantidadeParcelas = resultSet.getInt("quantidade_parcelas");

            // Determinar status automaticamente
            Date hoje = new Date();
            if (dataPagamento != null) {
                statusCalculado = "Pago";
            } else if (dataVencimento != null && dataVencimento.before(hoje)) {
                statusCalculado = "Vencido";
            } else {
                statusCalculado = "Pendente";
            }
        } else {
            response.sendRedirect("exibir_vencimentos.jsp?erro=registro_nao_encontrado");
            return;
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Erro ao buscar dados do vencimento: " + e.getMessage() + "</div>");
        e.printStackTrace();
    } finally {
        try {
            if (resultSet != null) {
                resultSet.close();
            }
        } catch (SQLException e) {
        }
        try {
            if (preparedStatement != null) {
                preparedStatement.close();
            }
        } catch (SQLException e) {
        }
        try {
            if (connection != null) {
                connection.close();
            }
        } catch (SQLException e) {
        }
    }
%>
<!DOCTYPE html>
<html lang="pt-BR">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Editar Vencimento</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
        <style>
            .card-vencimento {
                border-left: 4px solid #4e73df;
            }
            .info-label {
                font-weight: 600;
                color: #5a5c69;
            }
            .info-value {
                font-weight: 700;
            }
            .valor-total {
                color: #2e59d9;
            }
            .valor-parcela {
                color: #858796;
            }
            .status-badge {
                font-size: 0.75rem;
                font-weight: 700;
                padding: 0.35em 0.65em;
                border-radius: 0.25rem;
            }
            .status-pago {
                background-color: rgba(28, 200, 138, 0.1);
                color: #1cc88a;
            }
            .status-vencido {
                background-color: rgba(231, 74, 59, 0.1);
                color: #e74a3b;
            }
            .status-pendente {
                background-color: rgba(246, 194, 62, 0.1);
                color: #f6c23e;
            }
        </style>
    </head>
    <body>
        <div class="container py-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h1 class="h3 mb-0 text-gray-800">
                    <i class="bi bi-pencil-square me-2"></i>Editar Vencimento
                </h1>
                <a href="exibir_vencimentos.jsp" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left me-1"></i> Voltar
                </a>
            </div>

            <div class="card shadow mb-4 card-vencimento">
                <div class="card-header py-3">
                    <h6 class="m-0 font-weight-bold text-primary">Detalhes do Vencimento</h6>
                </div>
                <div class="card-body">
                    <div class="row mb-4">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <span class="info-label">Número do Pedido:</span>
                                <span class="info-value">#<%= nrPedido%></span>
                            </div>
                            <div class="mb-3">
                                <span class="info-label">Data de Vencimento:</span>
                                <span class="info-value"><%= new SimpleDateFormat("dd/MM/yyyy").format(dataVencimento)%></span>
                            </div>
                            <div class="mb-3">
                                <span class="info-label">Status:</span>
                                <span class="status-badge <%= "status-" + statusCalculado.toLowerCase()%>">
                                    <%= statusCalculado%>
                                </span>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <span class="info-label">Valor Total:</span>
                                <span class="info-value valor-total">R$ <%= df.format(valorTotalPedido)%></span>
                            </div>
                            <div class="mb-3">
                                <span class="info-label">Parcelas:</span>
                                <span class="info-value"><%= quantidadeParcelas%>x de R$ <%= df.format(valorParcelaAtual)%></span>
                            </div>
                            <% if (dataPagamento != null) {%>
                            <div class="mb-3">
                                <span class="info-label">Data Pagamento:</span>
                                <span class="info-value"><%= new SimpleDateFormat("dd/MM/yyyy").format(dataPagamento)%></span>
                            </div>
                            <% }%>
                        </div>
                    </div>

                    <form action="atualizar_vencimento.jsp" method="post">
                        <input type="hidden" name="id" value="<%= idVencimento%>">

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="prazo" class="form-label">Prazo (dias)</label>
                                <input type="number" class="form-control" id="prazo" name="prazo" 
                                       value="<%= prazoAtual%>" required min="0">
                            </div>

                            <div class="col-md-6 mb-3">
                                <label for="valor_parcela" class="form-label">Valor da Parcela</label>
                                <div class="input-group">
                                    <span class="input-group-text">R$</span>
                                    <input type="text" class="form-control" id="valor_parcela" name="valor_parcela" 
                                           value="<%= df.format(valorParcelaAtual)%>" readonly>
                                </div>
                            </div>
                        </div>

                        <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-4">
                            <button type="submit" class="btn btn-primary">
                                <i class="bi bi-save me-1"></i> Salvar Alterações
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            // Formatação do valor da parcela
            document.getElementById('valor_parcela').addEventListener('blur', function (e) {
                let value = this.value.replace(/[^\d,]/g, '').replace(',', '.');
                let num = parseFloat(value);
                if (!isNaN(num)) {
                    this.value = num.toLocaleString('pt-BR', {minimumFractionDigits: 2});
                }
            });

            // Validação do formulário
            document.querySelector('form').addEventListener('submit', function (e) {
                let valorParcela = document.getElementById('valor_parcela').value;
                valorParcela = valorParcela.replace(/\./g, '').replace(',', '.');

                if (isNaN(parseFloat(valorParcela))) {
                    e.preventDefault();
                    alert('Por favor, insira um valor válido para a parcela');
                    document.getElementById('valor_parcela').focus();
                }
            });
        </script>
        <a href="index.jsp" class="btn-voltar">
            <i class="fas fa-arrow-left"></i> Voltar ao Início
        </a>
    </body>
</html>