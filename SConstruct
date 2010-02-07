# -*- mode: python -*-
import os

env = Environment(ENV=os.environ)
env.Append(CFLAGS=' -std=c99 ')

ragel = Builder(action='ragel $SOURCE -o $TARGET', suffix='.c',
                src_suffix='.rl')
ragel_dot = Builder(action='ragel -V $SOURCE > $TARGET', suffix='.dot',
                    src_suffix='.rl')
env.Append(BUILDERS={'Ragel': ragel,
                     'RagelDot': ragel_dot})

pgn_ragel = env.Ragel('pgn')
pgn_lib = env.Library('pgn', ['pgn.c'])

env.Depends(pgn_lib, pgn_ragel)

pgn_dot = env.RagelDot('pgn')
env.Alias('dot', pgn_dot)

test_env = env.Clone()
test_env.Append(LIBS=[pgn_lib])
test = test_env.Program('test_pgn', ['test.c'])
test_alias = test_env.Alias('test', [test], test[0].abspath)
AlwaysBuild(test_alias)

env.Default([pgn_lib, pgn_dot])
