
insert into Position(teacherId, position, versionId) values ('GNG', 'director', '');
insert into Position(teacherId, position, versionId) values ('GNG', 'principal', 'KJV');

insert into Teacher(teacherId, fullname, pseudonym, passPhrase, authorizerId) values ('BOB112', 'Bob Smith', 'Bob', 'IntoTheDark', 'GNG');
insert into Position(teacherId, position, versionId) values ('BOB112', 'principal', 'KJV');

insert into Teacher(teacherId, fullname, pseudonym, passPhrase, authorizerId) values ('BILL112', 'Bill Jones', 'Bill', 'IntoTheLight', 'GNG');
insert into Position(teacherId, position, versionId) values ('BILL112', 'teacher', 'KJV');
insert into Position(teacherId, position, versionId) values ('BILL112', 'principal', 'KJV');

insert into Teacher(teacherId, fullname, pseudonym, passPhrase, authorizerId) values ('BOB1', 'Bob Ross', 'Bob R', 'IntoTheLight1', 'BILL112');
insert into Position(teacherId, position, versionId) values ('BOB1', 'teacher', 'KJV');

insert into Teacher(teacherId, fullname, pseudonym, passPhrase, authorizerId) values ('JOE1', 'Joe Rose', 'Joe', 'IntoTheLight2', 'BILL112');
insert into Position(teacherId, position, versionId) values ('JOE1', 'teacher', 'KJV');
insert into Position(teacherId, position, versionId) values ('JOE1', 'teacher', 'WEB');

insert into Teacher(teacherId, fullname, pseudonym, passPhrase, authorizerId) values ('JOHN1', 'John Rush', 'John', 'IntoTheLight3', 'BILL112');
insert into Position(teacherId, position, versionId) values ('JOHN1', 'teacher', 'KJV');
insert into Position(teacherId, position, versionId) values ('JOHN1', 'teacher', 'WEB');
insert into Position(teacherId, position, versionId) values ('JOHN1', 'teacher', 'KJVA');
insert into Position(teacherId, position, versionId) values ('JOHN1', 'board', '');

