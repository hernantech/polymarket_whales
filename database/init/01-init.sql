-- Initialize Polymarket Whales Database

-- Create extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create whales table
CREATE TABLE IF NOT EXISTS whales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    address VARCHAR(255) UNIQUE NOT NULL,
    total_volume DECIMAL(20, 2) DEFAULT 0,
    total_trades INTEGER DEFAULT 0,
    first_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create trades table
CREATE TABLE IF NOT EXISTS trades (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    whale_id UUID REFERENCES whales(id) ON DELETE CASCADE,
    market_id VARCHAR(255) NOT NULL,
    trade_type VARCHAR(50) NOT NULL,
    amount DECIMAL(20, 2) NOT NULL,
    price DECIMAL(20, 8) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create markets table
CREATE TABLE IF NOT EXISTS markets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    market_id VARCHAR(255) UNIQUE NOT NULL,
    question TEXT NOT NULL,
    category VARCHAR(100),
    total_volume DECIMAL(20, 2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_whales_address ON whales(address);
CREATE INDEX IF NOT EXISTS idx_whales_total_volume ON whales(total_volume DESC);
CREATE INDEX IF NOT EXISTS idx_trades_whale_id ON trades(whale_id);
CREATE INDEX IF NOT EXISTS idx_trades_market_id ON trades(market_id);
CREATE INDEX IF NOT EXISTS idx_trades_timestamp ON trades(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_markets_market_id ON markets(market_id);
CREATE INDEX IF NOT EXISTS idx_markets_status ON markets(status);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_whales_updated_at BEFORE UPDATE ON whales
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_markets_updated_at BEFORE UPDATE ON markets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data (optional)
INSERT INTO whales (address, total_volume, total_trades) VALUES
    ('0x1234567890123456789012345678901234567890', 1000000.00, 150),
    ('0xabcdefabcdefabcdefabcdefabcdefabcdefabcd', 750000.00, 100)
ON CONFLICT (address) DO NOTHING;

INSERT INTO markets (market_id, question, category, total_volume, status) VALUES
    ('market_001', 'Will Bitcoin reach $100k by end of 2024?', 'Crypto', 5000000.00, 'active'),
    ('market_002', 'Will the Federal Reserve cut rates in 2024?', 'Finance', 3000000.00, 'active')
ON CONFLICT (market_id) DO NOTHING;
