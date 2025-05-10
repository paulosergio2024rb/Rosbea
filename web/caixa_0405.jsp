<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Controle de Caixa</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <style>
            :root {
                --primary-color: #4361ee;
                --success-color: #4cc9f0;
                --danger-color: #f72585;
                --warning-color: #f8961e;
                --purple-color: #7209b7;
                --light-color: #f8f9fa;
                --dark-color: #212529;
                --border-radius: 6px;
                --box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            }

            body {
                font-family: 'Roboto', sans-serif;
                margin: 0;
                padding: 0;
                background-color: #f5f7fa;
                color: #333;
                line-height: 1.4;
            }

            .container {
                max-width: 1200px;
                margin: 0 auto;
                padding: 12px;
            }

            header {
                background-color: var(--primary-color);
                color: white;
                padding: 12px 0;
                margin-bottom: 16px;
                box-shadow: var(--box-shadow);
                border-radius: 0 0 var(--border-radius) var(--border-radius);
            }

            h1 {
                margin: 0;
                text-align: center;
                font-weight: 500;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 8px;
                font-size: 1.3rem;
            }

            .dashboard {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
                gap: 10px;
                margin-top: 16px;
            }

            .card {
                background-color: white;
                border-radius: var(--border-radius);
                padding: 10px;
                box-shadow: var(--box-shadow);
                transition: all 0.2s ease;
                text-align: center;
                border-top: 3px solid var(--primary-color);
                display: flex;
                flex-direction: column;
                height: 100%;
                min-height: 120px;
            }

            .card:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            }

            .card a {
                text-decoration: none;
                color: var(--dark-color);
                display: flex;
                flex-direction: column;
                align-items: center;
                height: 100%;
                justify-content: space-between;
                padding: 4px;
            }

            .card-icon {
                font-size: 1.6rem;
                margin-bottom: 6px;
                color: var(--primary-color);
                transition: transform 0.2s ease;
            }

            .card:hover .card-icon {
                transform: scale(1.05);
            }

            .card h2 {
                margin: 0 0 4px 0;
                font-weight: 500;
                color: var(--primary-color);
                font-size: 0.95rem;
            }

            .card p {
                margin: 0;
                color: #666;
                font-size: 0.75rem;
                line-height: 1.2;
            }

            /* Cores específicas para cada card */
            .receita-card {
                border-top-color: var(--success-color);
            }
            .receita-card .card-icon {
                color: var(--success-color);
            }

            .despesa-card {
                border-top-color: var(--danger-color);
            }
            .despesa-card .card-icon {
                color: var(--danger-color);
            }

            .exclusao-card {
                border-top-color: var(--warning-color);
            }
            .exclusao-card .card-icon {
                color: var(--warning-color);
            }

            .movimentacoes-card {
                border-top-color: var(--purple-color);
            }
            .movimentacoes-card .card-icon {
                color: var(--purple-color);
            }

            .pedidos-card {
                border-top-color: var(--warning-color);
            }
            .pedidos-card .card-icon {
                color: var(--warning-color);
            }

            /* ÚNICA ALTERAÇÃO REALIZADA */
            .separador-linhas {
                grid-column: 1 / -1;
                height: 30px;
            }

            @media (max-width: 768px) {
                .dashboard {
                    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
                }

                .card {
                    min-height: 110px;
                    padding: 8px;
                }

                .card-icon {
                    font-size: 1.4rem;
                }

                .card h2 {
                    font-size: 0.9rem;
                }
            }

            @media (max-width: 480px) {
                .dashboard {
                    grid-template-columns: 1fr 1fr;
                }

                h1 {
                    font-size: 1.2rem;
                }
            }

        </style>
    </head>

    <body>
        <header>
            <div class="container">
                <h1><i class="fas fa-cash-register"></i> Controle de Caixa</h1>
            </div>
        </header>

        <div class="container">
            <div class="dashboard">
                <!-- Primeira linha (4 cards) -->
                <div class="card receita-card">
                    <a href="abrir_caixa.jsp">
                        <i class="fas fa-hand-holding-usd card-icon"></i>
                        <div>
                            <h2>Abrir Caixa</h2>
                            <p>Abrir Caixa</p>
                        </div>
                    </a>
                </div>

                <div class="card receita-card">
                    <a href="registrar_entrada.jsp">
                        <i class="fas fa-hand-holding-usd card-icon"></i>
                        <div>
                            <h2>Registrar Receita</h2>
                            <p>Adicionar entradas</p>
                        </div>
                    </a>
                </div>

                <div class="card despesa-card">
                    <a href="registrar_saida.jsp">
                        <i class="fas fa-money-bill-wave card-icon"></i>
                        <div>
                            <h2>Registrar Despesa</h2>
                            <p>Registrar saídas</p>
                        </div>
                    </a>
                </div>

                <div class="card exclusao-card">
                    <a href="caixa_exclusao.jsp">
                        <i class="fas fa-trash-alt card-icon"></i>
                        <div>
                            <h2>Excluir Movimento</h2>
                            <p>Remover registros</p>
                        </div>
                    </a>
                </div>

                <!-- Separador entre linhas -->
                <div class="separador-linhas"></div>

                <!-- Segunda linha (3 cards) -->
                <div class="card movimentacoes-card">
                    <a href="listar_caixa.jsp">
                        <i class="fas fa-list-alt card-icon"></i>
                        <div>
                            <h2>Movimentações</h2>
                            <p>Histórico completo</p>
                        </div>
                    </a>
                </div>

                <div class="card pedidos-card">
                    <a href="buscar_pedido.jsp">
                        <i class="fas fa-box-open card-icon"></i>
                        <div>
                            <h2>Pagamentos</h2>
                            <p>Registrar pagamentos</p>
                        </div>
                    </a>
                </div>

                <div class="card movimentacoes-card">
                    <a href="fechar_caixa.jsp">
                        <i class="fas fa-list-alt card-icon"></i>
                        <div>
                            <h2>Fechar Caixa</h2>
                            <p>Fechar Caixa</p>
                        </div>
                    </a>
                </div>
            </div>
        </div>
    </body>
</html>