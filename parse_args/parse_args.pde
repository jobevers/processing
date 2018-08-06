import java.util.Map;

String myEnv = System.getenv("env_name");
print(myEnv);

Map<String, String> env = System.getenv();
for (String envName : env.keySet()) {
  System.out.format("%s=%s%n", 
    envName, 
    env.get(envName));
}

if (args != null) {
  println(args.length);
  for (int i = 0; i < args.length; i++) {
    println(args[i]);
  }
} else {
  println("args == null");
}
