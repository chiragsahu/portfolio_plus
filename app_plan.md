# Portfolio Plus App Enhancement Plan

## Overview
Portfolio Plus is an investment tracking and analysis app designed to help users make smarter investment decisions by comparing investments with various data points and visualizing returns in an intuitive way. The app will feature local data storage for offline functionality and support multiple portfolios organized by investment type.

## Current State Analysis
The app currently has:
- Basic navigation structure with Dashboard, Portfolio, Assets, Tools, and Profile sections
- Trade calculator with basic profit/loss calculations
- SIP calculator (basic and advanced versions)
- Basic portfolio widget showing current value, invested amount, and P&L
- Riverpod for state management
- Material Design UI with custom color scheme

## Proposed Enhancements

### 1. Multiple Portfolio Management
- Create a portfolio system where users can have multiple portfolios categorized by investment type:
  - Stocks
  - Cryptocurrency
  - Mutual Funds
  - Commodities
  - Bonds
  - Real Estate
  - Custom categories
- Each portfolio can have tags for platforms (e.g., Zerodha, Groww, Coinbase, Binance)
- Portfolio summary view with total value across all portfolios
- Individual portfolio detailed views

### 2. Local Data Storage with SQLite
- Implement SQLite database for local data persistence
- Store portfolio data, transactions, and historical prices
- Enable offline functionality with data synchronization when online
- Database schema design for efficient querying and reporting

### 3. Enhanced Portfolio Features
- Transaction management (buy, sell, dividend, deposit, withdrawal)
- Automatic calculation of average price, P&L, returns
- Asset allocation visualization
- Performance comparison between portfolios
- Historical performance tracking
- Sector/industry allocation for stock portfolios

### 4. Live Price Integration (Future)
- API integration for real-time price updates
- Price alerts and notifications
- Historical price data storage
- Price trend analysis

### 5. Improved UI/UX
- Interactive charts for portfolio visualization
- Better dashboard with portfolio overview
- Enhanced transaction entry forms
- Improved navigation and user flow
- Dark mode support

## Technical Architecture

### 1. State Management
- Continue with Riverpod for state management
- Create providers for portfolio data, transactions, and calculations
- Implement caching for frequently accessed data

### 2. Database Design
- Use `sqflite` package for SQLite implementation
- Tables: Portfolios, Transactions, Assets, Prices, Tags
- Relationships between tables for efficient querying

### 3. Data Models
- Portfolio model with investment type, tags, and metadata
- Transaction model with type, amount, quantity, date, and portfolio reference
- Asset model with symbol, name, current price, and historical data
- Tag model for categorization

### 4. Repository Pattern
- Implement repository classes for data access
- Abstract database operations
- Facilitate future API integration

## Implementation Phases

### Phase 1: Database and Models
1. Set up SQLite database
2. Create data models for portfolios, transactions, assets
3. Implement repository pattern
4. Create basic CRUD operations

### Phase 2: Portfolio Management
1. Implement portfolio creation and management
2. Add transaction entry functionality
3. Create portfolio detail views
4. Implement portfolio calculations (P&L, returns, etc.)

### Phase 3: UI/UX Improvements
1. Redesign dashboard with portfolio overview
2. Create interactive charts for portfolio visualization
3. Improve transaction entry forms
4. Add portfolio comparison features

### Phase 4: Advanced Features
1. Implement asset allocation visualization
2. Add historical performance tracking
3. Create portfolio analytics and insights
4. Add export functionality

### Phase 5: Live Price Integration (Future)
1. Integrate price APIs
2. Implement automatic price updates
3. Add price alerts
4. Enhance with real-time data

## File Structure Changes

```
lib/
├── main.dart
├── models/
│   ├── portfolio.dart
│   ├── transaction.dart
│   ├── asset.dart
│   └── tag.dart
├── modules/
│   ├── portfolio/
│   │   ├── view/
│   │   │   ├── portfolio_list_view.dart
│   │   │   ├── portfolio_detail_view.dart
│   │   │   ├── add_portfolio_view.dart
│   │   │   └── transaction_list_view.dart
│   │   ├── provider/
│   │   │   ├── portfolio_provider.dart
│   │   │   └── transaction_provider.dart
│   │   └── widgets/
│   │       ├── portfolio_card.dart
│   │       ├── transaction_form.dart
│   │       └── portfolio_chart.dart
│   ├── dashboard/
│   │   ├── view/
│   │   │   └── enhanced_dashboard_view.dart
│   │   └── widgets/
│   │       ├── portfolio_summary_widget.dart
│   │       └── performance_widget.dart
│   └── assets/
│       ├── view/
│       │   └── assets_view.dart
│       └── provider/
│           └── asset_provider.dart
├── services/
│   ├── database_service.dart
│   ├── portfolio_repository.dart
│   ├── transaction_repository.dart
│   └── price_service.dart (future)
└── utils/
    ├── app_utils.dart
    ├── colors.dart
    ├── ts.dart
    ├── constants.dart
    └── formatters.dart
```

## Dependencies to Add
- `sqflite`: For SQLite database implementation
- `path`: For database file path handling
- `equatable`: For value equality in models
- `json_annotation` and `json_serializable`: For JSON serialization
- `intl`: For date and currency formatting (already included)
- `fl_chart`: For charts (already included)

## Database Schema

### Portfolios Table
- id (INTEGER PRIMARY KEY)
- name (TEXT)
- description (TEXT)
- investment_type (TEXT) - enum: stocks, crypto, mutual_funds, etc.
- created_at (DATETIME)
- updated_at (DATETIME)

### Transactions Table
- id (INTEGER PRIMARY KEY)
- portfolio_id (INTEGER FOREIGN KEY)
- asset_id (INTEGER FOREIGN KEY)
- type (TEXT) - enum: buy, sell, dividend, deposit, withdrawal
- quantity (REAL)
- price (REAL)
- amount (REAL)
- date (DATETIME)
- notes (TEXT)
- created_at (DATETIME)

### Assets Table
- id (INTEGER PRIMARY KEY)
- symbol (TEXT)
- name (TEXT)
- current_price (REAL)
- last_updated (DATETIME)

### Tags Table
- id (INTEGER PRIMARY KEY)
- name (TEXT)
- type (TEXT) - enum: platform, sector, custom

### Portfolio_Tags Table (Many-to-Many)
- portfolio_id (INTEGER)
- tag_id (INTEGER)

## Key Features Implementation Details

### 1. Portfolio Creation Flow
- Select investment type (Stocks, Crypto, etc.)
- Enter portfolio name and description
- Add platform tags (optional)
- Set initial balance (optional)

### 2. Transaction Entry
- Select portfolio
- Select asset (search or create new)
- Enter transaction type (Buy/Sell)
- Enter quantity and price
- Auto-calculate amount
- Add date and notes

### 3. Portfolio Calculations
- Total value: Σ(current_price × quantity)
- Invested amount: Σ(buy_amount) - Σ(sell_amount)
- P&L: Total value - Invested amount
- P&L %: (P&L / Invested amount) × 100
- Average price: Weighted average of buy prices

### 4. Dashboard Enhancements
- Portfolio overview cards
- Total portfolio value
- Overall P&L
- Asset allocation pie chart
- Recent transactions
- Top performing portfolios

## Testing Strategy
1. Unit tests for models and repositories
2. Widget tests for UI components
3. Integration tests for database operations
4. Manual testing for user flows

## Future Enhancements
1. Cloud synchronization
2. Portfolio sharing
3. Advanced analytics
4. AI-powered insights
5. Social features
6. Tax reporting

## Architecture Addendum: Multi-account, Exchanges, Sub-accounts, and Saved Views ("Lens")

To support multiple providers (e.g., Zerodha, Groww) and crypto exchanges (e.g., Bybit with sub-accounts), adopt an account-first domain model with a flexible saved-view layer:

- Domain Concepts
  - Provider: A platform or broker (Zerodha, Groww, Bybit, Binance).
  - Account: A user account at a provider. Supports self-referencing parentId to model sub-accounts (e.g., Bybit Main, Bybit Trading Subaccount-1).
  - Asset: A security or instrument (stock, coin, mutual fund, bond, commodity).
  - Scope (internal): A filter that selects a set of Providers/Accounts/Sub-accounts/Assets/Tags and optional date range.
  - Lens (user-facing): A saved view mapped to an internal Scope. Users select a Lens to slice and aggregate analytics.

- Hierarchy
  Provider → Account → Sub-account → Asset → Transactions
  Aggregations flow upward: per Asset within Account, then to Account, Provider, and finally to Lens.

- Saved Views ("Lens")
  - Users can create multiple Lenses that capture selections like:
    - All Zerodha stocks only
    - All Groww stocks only
    - All Bybit sub-accounts individually or combined
    - Cross-provider slices (e.g., all Mutual Funds across Zerodha + Groww)
  - Each Lens can optionally override base currency for display.

- Examples
  - Stocks:
    - Zerodha Lens: shows realized/unrealized PnL for stocks held via Zerodha only.
    - Groww Lens: isolated view for Groww holdings.
  - Crypto:
    - Bybit Main vs Subaccount-1 vs Subaccount-2 Lenses: view realized/unrealized PnL individually, or one combined Lens including all sub-accounts.

## Multi-currency and FX

- Base Currency Setting
  - User-selectable base currency (INR or USD) stored in settings.
  - All monetary analytics are displayed in the chosen base currency.

- FX Storage
  - app_settings: stores key/value settings such as baseCurrency and manual USD→INR rate.
  - fx_rates: stores historical and latest FX rates for robust conversions and backtesting.

- Conversion and Formatting
  - A centralized conversion service formats values using base currency and applies FX conversion when needed.
  - Implemented initially for UI elements in the portfolio list, detail, and comparison screens using [settings_provider.dart](lib/modules/settings/provider/settings_provider.dart) and [currency_conversion_service.dart](lib/services/currency_conversion_service.dart).

## Database Additions (v2+)

Additive migrations (no destructive changes) to support providers, accounts, saved views (Lenses), and FX:

- providers
  - id, name, type (broker/exchange), metadata
- accounts
  - id, provider_id, name, parent_account_id (nullable) for sub-accounts, metadata
- scopes
  - id, name, filters JSON (providers/accounts/assets/tags/date-range), optional base_currency override
- portfolio_scopes (join if keeping legacy "Portfolio" as a convenience)
  - portfolio_id, scope_id
- app_settings
  - key TEXT PRIMARY KEY, value TEXT
- fx_rates
  - id, from_currency, to_currency, rate, as_of_utc, UNIQUE(from_currency, to_currency, as_of_utc)

Note: Existing tables for portfolios, transactions, assets, tags remain. Transactions should be extended (future phase) with account_id, fee, fee_currency, quote_currency, trade_id, and realized_pnl_per_tx to enable precise cost-basis and PnL attribution per Account/Sub-account.

## Analytics Acceptance Criteria

- Overview Tab
  - Renders with no data without errors.
  - Single-account case shows invested, value, realized PnL, unrealized PnL, and total return %.
  - Multi-account aggregation correctly sums values and converts currencies to base.
- Positions Tab
  - Group by Provider, Account, Sub-account, and Asset.
  - Columns: qty, avg cost, price, value, realized PnL, unrealized PnL, fees — all in base currency.
- PnL Tab
  - Realized/unrealized breakdown per node; date-range filters work; totals reconcile with Overview.
- Allocation Tab
  - Allocation by asset class/provider/account respects Lens filters and base-currency conversion.
- History Tab
  - Equity curve and net deposits over time handle FX consistently; backfills use historical fx_rates when present.

## Naming Decision

- User-facing name: Lens (maps to internal Scope)
  - Short, intuitive, communicates “a way of looking at your data”.
  - Alternatives considered: Scope, Basket, Deck, View, Hub, Stack. Lens selected for clarity and branding.