use postgres::{NoTls, Client, Error};
use std::error;

static CONNECTION_STRING: &str = "host=postgres user=grox dbname=grox password=29fc24ba5c7f99a5f750bb5edfc5aa04b4dea78f70b4eaab15521e16af99398f";

pub fn get_connection() -> Result<Client, Error> {
    Client::connect(CONNECTION_STRING, NoTls)
}

pub fn init_db() -> Result<(), Box<dyn error::Error>> {
    let mut client = get_connection()?;

    client.batch_execute("

    CREATE TABLE IF NOT EXISTS graphs (
        id SERIAL PRIMARY KEY
    );

    CREATE TABLE IF NOT EXISTS nodes (
        id SERIAL PRIMARY KEY,
        graph INTEGER NOT NULL
    );

    CREATE TABLE IF NOT EXISTS links (
        id SERIAL PRIMARY KEY,
        l INTEGER NOT NULL,
        r INTEGER NOT NULL
    );

    ")?;

    Ok(())
}