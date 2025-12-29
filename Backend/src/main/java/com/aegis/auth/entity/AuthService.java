import com.aegis.auth.repository.UserRepository;
import com.aegis.auth.entity.User;
import com.aegis.auth.dto.AuthResponse;
import com.aegis.auth.service.JwtService;
import com.aegis.auth.repository.MfaSecretRepository;
import com.aegis.auth.entity.MfaSecret.Status;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

  private final UserRepository repo;
  private final PasswordEncoder encoder;
  private final JwtService jwtService;
  private final MfaSecretRepository mfaRepo;

  public AuthService(...) { ... }

  public AuthResponse login(String email, String password) {

    User user = repo.findByEmail(email)
        .orElseThrow(() -> new RuntimeException("Invalid credentials"));

    if (!encoder.matches(password, user.getPasswordHash())) {
      throw new RuntimeException("Invalid credentials");
    }

    boolean mfaActive = mfaRepo.findByUserId(email)
        .map(s -> s.getStatus() == Status.ACTIVE)
        .orElse(false);

    if (mfaActive) {
      return AuthResponse.mfaRequired(email);
    }

    String token = jwtService.generateToken(email);
    return AuthResponse.success(token);
  }
}
