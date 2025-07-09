abstract class AIPromptBuilderRepository<T, D> {
  late T systemPrompt;
  late T userPrompt;

  void setSystemPrompt(String prompt);
  void setUserPrompt(String prompt);

  D buildPrompt();
}