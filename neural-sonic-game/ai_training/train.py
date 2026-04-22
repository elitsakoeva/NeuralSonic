from godot_rl.wrappers.stable_baselines_wrapper import StableBaselinesGodotEnv
from stable_baselines3 import PPO
import os

def train():
    env = StableBaselinesGodotEnv(
        env_path = None,
        show_window = True,
        speedup = 1
    )

    model = PPO(
        "MultiInputPolicy",
        env,
        verbose=1,
        n_steps=2048,
        batch_size=64,
        learning_rate=0.0003,
        tensorboard_log="./logs/"
    )

    print("Training starts.")
    model.learn(total_timesteps = 500_000)

    os.makedirs("models", exist_ok = True)
    model.save("models/sonic_ai")
    print("Model saved. ")

    env.close()


if __name__ == "__main__":
    train()