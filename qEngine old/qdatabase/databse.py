import sqlalchemy as _sql
import sqlalchemy.ext.declarative as _declarative
import sqlalchemy.orm as _orm


DATABASE_URL = "postgresql://lukasio:xbox3601@localhost/qdatabase"


engine = _sql.create_engine(DATABASE_URL)

SessionLocal = _orm.sessionmaker(autocommit=False,autoFlush=False,bind=engine)

Base = _declarative.declarative_base()