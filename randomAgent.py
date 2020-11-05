import retro

def main():


	env = retro.make(game='ContraForce-Nes')
	obs = env.reset()

	while True:

		obs,rew,done,info = env.step(env.action_space.sample())
		env.render()

		if done:
			obs = env.reset()
			pass

	env.close()



if __name__ == '__main__':
	main()