env = Environment()
env.Append(CCFLAGS = ['/Zi', '/Fd${TARGET}.pdb'])
env.Append(LINKFLAGS = ['/DEBUG'])
SConscript(['boot/SConscript'], variant_dir='build', duplicate=0, exports=["env"])