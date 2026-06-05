# mobile_arquitetura_01

Projeto Flutter desenvolvido como trabalho final da disciplina de Arquitetura Mobile. Consome a API [DummyJSON](https://dummyjson.com) e implementa autenticação, listagem de produtos, detalhes e controle de favoritos.

---

## Funcionalidades

- Login com autenticação via API (POST /auth/login)
- Validação de campos e tratamento de erros no login
- Sessão de usuário autenticado com bloqueio de acesso sem login
- Listagem de produtos com título, preço e imagem
- Tela de detalhes com nome, preço, descrição e imagem
- Controle de favoritos (marcar/desmarcar) com atualização automática da interface
- Logout com retorno à tela de login
- Tratamento de carregamento e erros nas requisições

---

## Tecnologias

- Flutter + Dart
- [Riverpod](https://riverpod.dev) — gerenciamento de estado
- [http](https://pub.dev/packages/http) — requisições HTTP
- [DummyJSON](https://dummyjson.com) — API de produtos e autenticação

---

## Arquitetura

O projeto segue uma organização em camadas inspirada em Clean Architecture:

```
lib/
├── core/
│   ├── errors/          # Classe Failure
│   └── network/         # HttpClient
├── data/
│   ├── datasources/     # Acesso remoto (auth, produtos) e cache
│   └── models/          # Modelos de dados (JSON)
├── domain/
│   ├── entities/        # Entidades de domínio (Product, User)
│   └── repositories/    # Contratos dos repositórios
└── presentation/
    ├── pages/           # Telas (Login, Produtos, Detalhes, Formulário)
    ├── providers/       # Providers Riverpod (auth, produtos)
    ├── states/          # Classes de estado
    └── viewmodels/      # ViewModel auxiliar
```

---

## Como executar

**Pré-requisitos:** Flutter SDK instalado e configurado.

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/mobile_arquitetura_01.git
cd mobile_arquitetura_01

# Instale as dependências
flutter pub get

# Execute o projeto
flutter run
```

---

## Credenciais de teste

A API DummyJSON aceita qualquer usuário do endpoint `/users`. Para teste rápido:

| Campo   | Valor         |
|---------|---------------|
| Usuário | `emilys`      |
| Senha   | `emilyspass`  |

---

## Gerenciamento de estado

O projeto usa **Riverpod** com `StateNotifierProvider`:

- `authProvider` — gerencia a sessão do usuário (login/logout)
- `productListProvider` — gerencia a lista de produtos, favoritos e erros

A interface é reconstruída automaticamente via `ref.watch` sempre que o estado muda, sem necessidade de `setState` manual.

---

## API utilizada

Base URL: `https://dummyjson.com`

| Endpoint        | Método | Uso                        |
|-----------------|--------|----------------------------|
| `/auth/login`   | POST   | Autenticação do usuário    |
| `/products`     | GET    | Lista de produtos          |

